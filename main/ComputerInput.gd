extends "PlayerInput.gd"

var pressed = {}
var was_pressed = {}


func _init().(1):
	for action in actions.keys():
		pressed[action] = 0
		was_pressed[action] = false


func _ready():
	process_priority = 10


func set_mappings(mappings):
	.set_mappings(mappings)
	for action in mappings.keys():
		# TODO: map to other action so they keep the same value
		pressed[action] = 0
		was_pressed[action] = false


func press(action):
	pressed[action] = 1


func release(action):
	pressed[action] = 0
	was_pressed[action] = true


func is_pressed(action):
	return pressed[action] > 0


func is_just_pressed(action):
	return is_pressed(action) and not was_pressed[action]


func is_just_released(action):
	return not is_pressed(action) and was_pressed[action]


func direction_pressed():
	var dir = Vector2()
	if is_pressed('left'):
		dir.x -= 1
	if is_pressed('right'):
		dir.x += 1
	if is_pressed('up'):
		dir.y -= 1
	if is_pressed('down'):
		dir.y += 1
	return dir


func _process(delta):
	# was_pressed should only state true for one tick
	#  Setting process_priority to 10 should ensure this gets handled
	#  after any relevant processing
	for key in was_pressed:
		was_pressed[key] = false
