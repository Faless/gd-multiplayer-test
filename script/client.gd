extends Control

func _ready():
	network.connect("client_message", self, "client_message")
	network.connect("server_message", self, "server_message")

func _on_listen_toggled( pressed ):
	network.create_client(
		get_node("Panel/config/host/LineEdit").get_text(), 
		int(get_node("Panel/config/port/LineEdit").get_text()))

func client_message(id, message):
	get_node("Panel/msg/Label").add_text("From " + str(id) + ":" + bytes2var(message) + "\n")

func server_message(message):
	print("recv")
	get_node("Panel/msg/Label").add_text("Server:" + bytes2var(message) + "\n")

func _on_Send_pressed():
	if get_node("Panel/msg/send/LineEdit").get_text() != "":
		network.send(var2bytes(get_node("Panel/msg/send/LineEdit").get_text()))
		print("send")
	get_node("Panel/msg/send/LineEdit").set_text("")
