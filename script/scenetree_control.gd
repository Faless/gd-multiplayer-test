extends Panel

var _selected = true
var _tex = null
var _tree = null

onready var _Control = get_node("Control")

func _ready():
	_Control.set_focus_mode(FOCUS_ALL)

func get_sub_tree():
	return _tree

func start(scene, singletons=[]):
	_tree = SceneTree.new()
	_tree.init()
	_tree.get_root().set_size(_Control.get_size())
	_tree.get_root().set_attach_to_screen_rect(_Control.get_global_rect())
	_tex = _tree.get_root().get_texture()
	
	for s in singletons:
		_tree.get_root().add_child(s)
	_tree.get_root().add_child(scene)
	
	get_node("Control/TextureRect").set_texture(_tex)

	set_process(true)
	set_fixed_process(true)

func _notification(what):
	if what == NOTIFICATION_RESIZED and _tree != null:
		call_deferred("_update_tree_rect")

func _update_tree_rect():
	_tree.get_root().set_size(_Control.get_size())
	_tree.get_root().set_attach_to_screen_rect(_Control.get_global_rect())

func _process(delta):
	if _tree == null:
		return

	_tree.idle(delta)

func _fixed_process(delta):
	if _tree == null:
		return

	_tree.iteration(delta)

func _exit_tree():
	if _tree != null:
		_tree.finish()

func _on_Control_input_event( ev ):
	if _tree != null:
		if ev.type == InputEvent.MOUSE_BUTTON:
			_Control.grab_focus()
		_tree.get_root().input(ev)
		accept_event()
