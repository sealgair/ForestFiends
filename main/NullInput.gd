extends "PlayerInput.gd"

func _input(_player=null):
	pass

func is_pressed(action):
	return false

func is_just_pressed(action):
	return false

func is_just_released(action):
	return false

func direction_pressed():
	return Vector2()
	
func direction_just_pressed(_flip=false):
	return Vector2()
	
func direction_just_released(_flip=false):
	return Vector2()
