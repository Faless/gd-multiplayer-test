extends Control

onready var network = get_node("/root/network")

func _ready():
	network.connect("client_message", self, "client_message")

func _on_listen_toggled( pressed ):
	if pressed:
		network.create_server(int(get_node("Panel/config/port/LineEdit").get_text()))
	else:
		network.clear()

func client_message(id, message):
	log_data(["From ", id, ": ", bytes2var(message)])

func _on_Send_pressed():
	if get_node("Panel/msg/send/LineEdit").get_text() != "":
		network.broadcast(var2bytes(get_node("Panel/msg/send/LineEdit").get_text()))
	get_node("Panel/msg/send/LineEdit").set_text("")

func log_data(data):
	var msg = ""
	for d in data:
		msg += str(d)
	msg += "\n"
	get_node("Panel/msg/Label").add_text(msg)