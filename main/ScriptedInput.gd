extends "ComputerInput.gd"

var action_script
var elapsed = 0


func _init(script).(0):
	action_script = script

func press(action, time=0.05):
	pressed[action] = time

func do_process(delta):
	for action in actions.keys():
		was_pressed[action] = pressed[action] > 0
		pressed[action] = max(0, pressed[action] - delta)

	for step in action_script:
		if not step['done'] and elapsed > step['start']:
			press(step['action'], step['time'])
			step['done'] = true
	
	elapsed += delta
