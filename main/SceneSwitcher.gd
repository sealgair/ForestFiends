extends CanvasLayer

var screens = {
	'select': preload("res://screens/character_select/CharacterSelect.tscn"),
	'choose_map': preload("res://screens/map_picker/MapPicker.tscn"),
	'play': preload("res://screens/arena/Arena.tscn"),
	'victory': preload("res://screens/victory/Victory.tscn"),
	'highscores': preload("res://screens/highscores/Highscores.tscn"),
	'stats': preload("res://screens/stats/Stats.tscn"),
	'info': preload("res://screens/info/AminalInfo.tscn"),
	'demo': preload("res://screens/demo/Demo.tscn"),
}

func change_scene(screen_name, parameters={}, transition='fade'):
	# copy existing screen
	var screenshot = get_tree().get_root().get_texture().get_data()
	var screentext = ImageTexture.new()
	screentext.create_from_image(screenshot)
	$Interstitial.texture = screentext
	
	var screen = screens[screen_name].instance()
	for prop in parameters:
		screen.set(prop, parameters[prop])

	$Interstitial.modulate = Color("ffffffff")
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	root.add_child(screen)
	current_scene.queue_free()
	
	$AnimationPlayer.play_backwards('fade')
	yield($AnimationPlayer,'animation_finished')