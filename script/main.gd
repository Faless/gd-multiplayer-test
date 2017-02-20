extends Node

const NET = preload("res://script/network.gd")
const SERVER = preload("res://scene/server.tscn")
const CLIENT = preload("res://scene/client.tscn")

var _tex = null
var _tree = SceneTree.new()

func _ready():
	node_setup(get_node("GridContainer/Server"), SERVER)
	node_setup(get_node("GridContainer/Client1"), CLIENT)
	node_setup(get_node("GridContainer/Client2"), CLIENT)
	node_setup(get_node("GridContainer/Client3"), CLIENT)
	pass

func node_setup(node, scene):
	var net = NET.new()
	net.set_name("network")
	node.start(scene.instance(), [net])