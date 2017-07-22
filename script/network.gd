extends Node

# I know, it's a lot of code, but I could not find any other way to have authoritative (safe) server.
# See comments below because a patch to Godot Engine is needed for making this really authoritative.

# Use as a signleton.
# Each peer will store the structure like this:
# - root
#   - network
#     - client_id1
#     - client_id2
#     - ...
#
# "network" is controlled by the server (and if you want, root can be too) and will be used to communicate.
# This channel is used from the server to communicate to the clients.
# If you set the root node as owned by the server, you can use regular RPC to call functions from server
# to clients, but not the other way around.
#
# Each "network" _subnode_ is controlled by the client with the respective ID and will be used as a feedback channel
# for the server.
# This channel can also be used to send client to client messages without the server handling it
# (it will still flow through the server, so malicious server can read it!)


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
		set_network_master(id)
		
	
	# This will be called on the server and with the patch will be guaranteed to be from this client
	remote func client_message(message):
		emit_signal("client_message", id, message)

var _has_peer = false
var _clients = {}

func _init():
	add_user_signal("server_message",[{"name":"message","type":TYPE_RAW_ARRAY}])
	add_user_signal("client_message", [
		{"name":"id","type":TYPE_INT},
		{"name":"message","type":TYPE_RAW_ARRAY}])

func broadcast(message):
	for id in _clients:
		send(message, int(id))

func send(message, id=1):
	if not _has_peer:
		return

	if is_network_master():
		rpc_id(id, "server_message", message)
	else:
		if _clients.has(get_tree().get_network_unique_id()):
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
	_has_peer = true
	var host = NetworkedMultiplayerENet.new()
	host.create_server(port,clients)
	get_tree().set_network_peer(host)
	get_tree().connect("network_peer_connected", self, "peer_connected")
	get_tree().connect("network_peer_disconnected", self, "peer_disconnected")
	#set_network_remote_owner(1)

func create_client(ip, port):
	_has_peer = true
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
	get_tree().set_network_peer(null)
	_has_peer = false
	if get_tree().is_connected("connected_to_server", self, "client_connected"):
		get_tree().disconnect("connected_to_server", self, "client_connected")
		get_tree().disconnect("connection_failed", self, "connect_failed")
		get_tree().disconnect("server_disconnected", self, "client_disconnect")
	elif get_tree().is_connected("network_peer_connected", self, "peer_connected"):
		get_tree().disconnect("network_peer_connected", self, "peer_connected")
		get_tree().disconnect("network_peer_disconnected", self, "peer_disconnected")