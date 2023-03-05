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

func start_transition(animation_options=[], direction=Vector2i()):
	if animation_options == []:
		animation_options = animations.keys()
	var animation = Global.rand_choice(animation_options)
	if direction.x == 0:
		direction.x = asign(randf()-.5)
	if direction.y == 0:
		direction.y = asign(randf()-.5)
		
	# copy existing screen
	var screenshot = get_tree().get_root().get_texture().get_image()
	var screentext = ImageTexture.create_from_image(screenshot)
	
	$Interstitial.texture = screentext
	$Interstitial.material.set_shader_parameter("time", 0)
	$Interstitial.material.set_shader_parameter("animation", animations[animation])
	$Interstitial.material.set_shader_parameter("direction", direction)
	$Interstitial.visible = true
	
func end_transition():
	$AnimationPlayer.play("shade")
	await $AnimationPlayer.animation_finished
	$Interstitial.visible = false
	$AnimationPlayer.play("RESET")

func change_to_scene(screen_name, parameters={}, animation_options=[], direction=Vector2()):
	start_transition(animation_options, direction)
	var screen = screens[screen_name].instantiate()
	for prop in parameters:
		screen.set(prop, parameters[prop])
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	root.add_child(screen)
	root.remove_child(current_scene)
	current_scene.queue_free()
	end_transition()
