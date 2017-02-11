extends Control

func _ready():
	network.connect("client_message", self, "client_message")

func _on_listen_toggled( pressed ):
	network.create_server(int(get_node("Panel/config/port/LineEdit").get_text()))

func client_message(id, message):
	get_node("Panel/msg/Label").add_text("From " + str(id) + ":" + bytes2var(message))

func _on_Send_pressed():
	if get_node("Panel/msg/send/LineEdit").get_text() != "":
		network.broadcast(var2bytes(get_node("Panel/msg/send/LineEdit").get_text()))
	get_node("Panel/msg/send/LineEdit").set_text("")
