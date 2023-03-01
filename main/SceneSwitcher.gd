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
	'fall': 3,
	'swipe': 4,
}

static func asign(v):
	if v >= 0: return 1
	else: return -1

func play_transition(animation_options=[], direction=Vector2()):
	# copy existing screen
	var screenshot = get_tree().get_root().get_texture().get_data()
	var screentext = ImageTexture.new()
	screentext.create_from_image(screenshot)
	
	if animation_options == []:
		animation_options = animations.keys()
	var animation = Global.rand_choice(animation_options)
	if direction.x == 0:
		direction.x = asign(randf()-.5)
	if direction.y == 0:
		direction.y = asign(randf()-.5)
	
	$Interstitial.texture = screentext
	$Interstitial.material.set_shader_param("time", 0)
	$Interstitial.material.set_shader_param("animation", animations[animation])
	$Interstitial.material.set_shader_param("direction", direction)
	$Interstitial.visible = true
	
	yield()
	
	$AnimationPlayer.play("shade")
	yield($AnimationPlayer,'animation_finished')
	$Interstitial.visible = false

func change_scene(screen_name, parameters={}, animation_options=[], direction=Vector2()):
	var player = play_transition(animation_options, direction)
	var screen = screens[screen_name].instance()
	for prop in parameters:
		screen.set(prop, parameters[prop])
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	root.add_child(screen)
	current_scene.queue_free()
	player.resume()
