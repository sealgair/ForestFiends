extends Object

var player_order = 1
var actions = {}

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


func is_pressed(action):
	return Input.is_action_pressed(actions[action])


func is_just_pressed(action):
	return Input.is_action_just_pressed(actions[action])


func is_just_released(action):
	return Input.is_action_just_released(actions[action])


func direction_pressed():
	return Vector2(
		Input.get_axis(actions['left'], actions['right']),
		Input.get_axis(actions['up'], actions['down'])
	)
