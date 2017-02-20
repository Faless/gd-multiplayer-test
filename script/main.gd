extends Node

const NET = preload("res://script/network.gd")
const SERVER = preload("res://scene/server.tscn")
const CLIENT = preload("res://scene/client.tscn")
const TESTS = preload("res://script/tests.gd")

onready var _Serv = get_node("GridContainer/Server")
onready var _C1 = get_node("GridContainer/Client1")
onready var _C2 = get_node("GridContainer/Client2")
onready var _C3 = get_node("GridContainer/Client3")

var _tex = null
var _tree = SceneTree.new()

func _ready():
	node_setup(_Serv, SERVER)
	node_setup(_C1, CLIENT)
	node_setup(_C2, CLIENT)
	node_setup(_C3, CLIENT)
	TESTS.setup(_get_net(_Serv), [_get_net(_C1),_get_net(_C2),_get_net(_C3)])

func node_setup(node, scene):
	var net = NET.new()
	net.set_name("network")
	var inst = scene.instance()
	node.start(scene.instance(), [net])
	var t = node.get_sub_tree()
	if t.get_root().has_node("Server"):
		t.get_root().get_node("Server")._on_listen_toggled(true)
		t.get_root().get_node("Server/Panel/config/listen").set_disabled(true)
	else:
		t.get_root().get_node("Client")._on_listen_toggled(true)
		t.get_root().get_node("Client/Panel/config/connect").set_disabled(true)

func _on_Impersonate_pressed():
	TESTS.test_impersonate()

func _get_net(node):
	var t = node.get_sub_tree()
	return t.get_root().get_node("network")