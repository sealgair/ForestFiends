extends CanvasLayer

const screens = {
	'select': preload("res://screens/character_select/CharacterSelect.tscn"),
	'choose_map': preload("res://screens/map_picker/MapPicker.tscn"),
	'play': preload("res://screens/arena/Arena.tscn"),
	'victory': preload("res://screens/victory/Victory.tscn"),
	'highscores': preload("res://screens/highscores/Highscores.tscn"),
	'stats': preload("res://screens/stats/Stats.tscn"),
	'info': preload("res://screens/info/AminalInfo.tscn"),
	'demo': preload("res://screens/demo/Demo.tscn"),
}
const animations = {
	'diagonal': 0,
	'circle': 1,
	'quad': 2,
}

func change_scene(screen_name, parameters={}, animation='random'):
	# copy existing screen
	var screenshot = get_tree().get_root().get_texture().get_data()
	var screentext = ImageTexture.new()
	screentext.create_from_image(screenshot)
	
	if animation == 'random':
		animation = Global.rand_choice(animations.keys())
	
	$Interstitial.texture = screentext
	$Interstitial.material.set_shader_param("time", 0)
	$Interstitial.material.set_shader_param("animation", animations[animation])
	$Interstitial.visible = true
	
	var screen = screens[screen_name].instance()
	for prop in parameters:
		screen.set(prop, parameters[prop])
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	root.add_child(screen)
	current_scene.queue_free()
	
	$AnimationPlayer.play("shade")
	yield($AnimationPlayer,'animation_finished')
	$Interstitial.visible = false
