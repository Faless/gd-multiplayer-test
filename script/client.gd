extends Control

onready var network = get_node("/root/network")

func _ready():
	network.connect("client_message", self, "client_message")
	network.connect("server_message", self, "server_message")

func _on_listen_toggled( pressed ):
	network.create_client(
		get_node("Panel/config/host/LineEdit").get_text(), 
		int(get_node("Panel/config/port/LineEdit").get_text()))

func client_message(id, message):
	log_data(["From " + str(id) + ": " + bytes2var(message)])

func server_message(message):
	log_data(["Server: " + bytes2var(message)])

func _on_Send_pressed():
	if get_node("Panel/msg/send/LineEdit").get_text() != "":
		network.send(var2bytes(get_node("Panel/msg/send/LineEdit").get_text()))
	get_node("Panel/msg/send/LineEdit").set_text("")

func log_data(data):
	var msg = ""
	for d in data:
		msg += str(d)
	msg += "\n"
	get_node("Panel/msg/Label").add_text(msg)
	printt(self, "Client log:" + msg)