extends Node2D

var player_order = 1
var actions = {}
var enabled = true

func _init(player):
	player_order = player
	
	for action in ['right', 'left', 'up', 'down', 'a', 'b']:
		actions[action] = "ui_{action}{p}".format({
			'action': action,
			'p': player_order
		})

func set_mappings(mappings):
	for key in mappings:
		var action = mappings[key]
		actions[key] = actions[action]

func override():
	return false

func is_pressed(action):
	return Input.is_action_pressed(actions[action])

func is_just_pressed(action):
	return Input.is_action_just_pressed(actions[action])

func is_any_just_pressed(action_choices):
	for action in action_choices:
		if is_just_pressed(action):
			return true
	return false

func is_just_released(action):
	return Input.is_action_just_released(actions[action])

func direction_pressed():
	return Vector2(
		Input.get_axis(actions['left'], actions['right']),
		Input.get_axis(actions['up'], actions['down'])
	)

func direction_just_pressed(flip=false):
	var dir = Vector2(0,0)
	if is_just_pressed('left'):
		dir.x -= 1
	if is_just_pressed('right'):
		dir.x += 1
	if is_just_pressed('up'):
		dir.y -= 1
	if is_just_pressed('down'):
		dir.y += 1
	if flip:
		dir = Vector2(dir.y, dir.x)
	return dir

func direction_just_released(flip=false):
	var dir = Vector2(0,0)
	if is_just_released('left'):
		dir.x -= 1
	if is_just_released('right'):
		dir.x += 1
	if is_just_released('up'):
		dir.y -= 1
	if is_just_released('down'):
		dir.y += 1
	if flip:
		dir = Vector2(dir.y, dir.x)
	return dir
