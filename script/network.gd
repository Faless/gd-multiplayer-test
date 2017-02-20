extends Node

# I know, it's a lot of code, but I could not find any other way to have authoritative (safe) server

# Safe communication channel with the client
class Client extends Node:
	var id = 0
	
	func _init(id=0):
		add_user_signal("client_message", [
			{"name":"id","type":TYPE_INT},
			{"name":"message","type":TYPE_RAW_ARRAY}])
		self.id = id
	
	func _ready():
		set_name(str(id))
		if get_tree().get_network_unique_id():
			set_network_mode(NETWORK_MODE_MASTER)
		else:
			set_network_mode(NETWORK_MODE_SLAVE)
		
		### This is a small patch I made.
		### It restricts the calling client to the specific ID.
		### See: https://github.com/Faless/godot/commit/24d3cef2b7b39fc1ef2df72ec1d3d7152e59a963
		#set_network_remote_owner(id) # Disable if building without patch (clients can impersonate each other)
	
	# This will be called on the server and with the patch will be guaranteed to be from this client
	remote func client_message(message):
		emit_signal("client_message", id, message)


func _init():
	add_user_signal("server_message",[{"name":"message","type":TYPE_RAW_ARRAY}])
	add_user_signal("client_message", [
		{"name":"id","type":TYPE_INT},
		{"name":"message","type":TYPE_RAW_ARRAY}])

var _clients = {}

func broadcast(message):
	for id in _clients:
		send(message, int(id))

func send(message, id=1):
	if is_network_master():
		rpc_id(id, "server_message", message)
	else:
		_clients[get_tree().get_network_unique_id()].rpc_id(id, "client_message", message)

# This will be called on the client
remote func server_message(message):
	emit_signal("server_message", message)

# This will be called on the server
func _client_message(id, message):
	emit_signal("client_message", id, message)

func peer_connected(id):
	# Send already conntected clients to new client
	for c in _clients:
		rpc_id(id, "add_client", c)
	# Add new client everywhere
	rpc("add_client", id)

func peer_disconnected(id):
	rpc("remove_client", id)

# Called on both client and server
sync func add_client(id):
	var c = Client.new(id)
	c.connect("client_message",self,"_client_message")
	_clients[id] = c
	add_child(c)

# Called on both client and server
sync func remove_client(id):
	if _clients.has(id):
		_clients[id].disconnect("client_message",self,"_client_message")
		_clients[id].queue_free()
		_clients.erase(id)

func create_server(port, clients=4):
	var host = NetworkedMultiplayerENet.new()
	host.create_server(port,clients)
	get_tree().set_network_peer(host)
	get_tree().connect("network_peer_connected", self, "peer_connected")
	get_tree().connect("network_peer_disconnected", self, "peer_disconnected")
	#set_network_remote_owner(1)

func create_client(ip, port):
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip,port)
	get_tree().set_network_peer(client)
	get_tree().connect("connected_to_server", self, "client_connected")
	get_tree().connect("connection_failed", self, "connect_failed")
	get_tree().connect("server_disconnected", self, "client_disconnect")
	#set_network_remote_owner(1)

func client_connected():
	pass
	# TODO Emit connection ok!

func connect_failed():
	clear()
	# TODO Emit connection error

func client_disconnect():
	clear()
	# TODO Emit disconnect

func clear():
	for id in _clients:
		_clients[id].disconnect("client_message",self,"_client_message")
		_clients[id].queue_free()
		_clients.erase(id)