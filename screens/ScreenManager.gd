extends Node

var screens = {
	'select': preload("res://screens/character_select/CharacterSelect.tscn"),
	'play': preload("res://screens/arena/Map.tscn"),
	'victory': preload("res://screens/victory/Victory.tscn"),
}

func _ready():
	pass # Replace with function body.
	

func load_screen(screen_name, parameters={}):
	var screen = screens[screen_name].instance()
	for prop in parameters:
		screen.set(prop, parameters[prop])
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	root.add_child(screen)
	current_scene.queue_free()
