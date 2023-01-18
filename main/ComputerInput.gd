extends "PlayerInput.gd"

var pressed = {}
var just_pressed = {}

func _init(player).(player):
	for action in actions:
		pressed[action] = 0


func press(action, time=0.1):
	pressed[action] = time


func is_pressed(action):
	return pressed[action] > 0


func is_just_pressed(action):
	return Input.is_action_just_pressed(actions[action])
