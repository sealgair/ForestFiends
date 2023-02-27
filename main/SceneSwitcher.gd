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

func change_scene(screen_name, parameters={}, transition='shade'):
	# copy existing screen
	var screenshot = get_tree().get_root().get_texture().get_data()
	var screentext = ImageTexture.new()
	screentext.create_from_image(screenshot)
	$Interstitial.position = Vector2()
	$Interstitial.texture = screentext
	$Interstitial.modulate = Color("ffffffff")
	$Interstitial.material.set_shader_param("time", 0)
	$Interstitial.visible = true
	
	var screen = screens[screen_name].instance()
	for prop in parameters:
		screen.set(prop, parameters[prop])
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	root.add_child(screen)
	current_scene.queue_free()
	
	$AnimationPlayer.play(transition)
	yield($AnimationPlayer,'animation_finished')
	$Interstitial.visible = false
