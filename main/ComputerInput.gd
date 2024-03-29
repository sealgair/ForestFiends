extends "PlayerInput.gd"

var pressed = {}
var was_pressed = {}
var overrides = {}

func _init(_player):
	super._init(_player)
	for action in actions.keys():
		pressed[action] = 0
		was_pressed[action] = false
	
	for action in ['a', 'b']:
		overrides[action] = "ui_{action}{p}".format({
			'action': action,
			'p': player_order
		})

func _ready():
	process_priority = 10

func set_mappings(mappings):
	super.set_mappings(mappings)
	for action in mappings.keys():
		# TODO: map to other action so they keep the same value
		pressed[action] = 0
		was_pressed[action] = false

func override():
	return Input.is_action_pressed(overrides['a']) \
		and Input.is_action_pressed(overrides['b'])

func press(action):
	pressed[action] = 1

func press_axis(direction):
	if direction.y > 0:
		press('down')
	elif direction.y < 0:
		press('up')
	if direction.x > 0:
		press('right')
	elif direction.x < 0:
		press('left')

func hold(action):
	pressed[action] = 2

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

func _process(_delta):
	#  Setting process_priority to 10 should ensure this gets handled
	#  after any relevant processing
	for action in actions.keys():
		# was_pressed should only state true for one tick
		was_pressed[action] = false
		if pressed[action] == 1:
			pressed[action] = 0
		# otherwise it's being held, so keep it
