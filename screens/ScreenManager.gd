extends Node

var screens = {
	'select': preload("res://screens/character_select/CharacterSelect.tscn"),
	'choose_map': preload("res://screens/map_picker/MapPicker.tscn"),
	'play': preload("res://screens/arena/Arena.tscn"),
	'victory': preload("res://screens/victory/Victory.tscn"),
	'highscores': preload("res://screens/highscores/Highscores.tscn"),
	'stats': preload("res://screens/stats/Stats.tscn"),
	'info': preload("res://screens/info/AminalINfo.tscn"),
}


func load_screen(screen_name, parameters={}):
	var screen = screens[screen_name].instance()
	for prop in parameters:
		screen.set(prop, parameters[prop])
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	root.add_child(screen)
	current_scene.queue_free()
