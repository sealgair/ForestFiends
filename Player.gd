extends KinematicBody2D

export (int) var player = 1

var inputs = {}
var run_speed = 100
var jump_speed = -450
var gravity = 1200

var screen_size
signal hit

var velocity = Vector2()
var jumping = false
var size = Vector2(16, 16) # todo: dynamic

func _ready():
	screen_size = get_viewport_rect().size
	# button mappings
	inputs['right'] = "move_right{p}".format({'p': player}) 
	inputs['left'] = "move_left{p}".format({'p': player}) 
	inputs['special'] = "move_special{p}".format({'p': player}) 
	inputs['attack'] = "move_attack{p}".format({'p': player}) 

func get_input():
	velocity.x = 0
	if Input.is_action_pressed(inputs['right']):
		velocity.x += run_speed
		$AnimatedSprite.flip_h = true
	if Input.is_action_pressed(inputs['left']):
		velocity.x -= run_speed
		$AnimatedSprite.flip_h = false
		
	var jump = Input.is_action_just_pressed(inputs['special'])
	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	position.x = wrapf(position.x, -size.x, screen_size.x)
	position.y = wrapf(position.y, -size.y, screen_size.y)

func _process(delta):
	if velocity.x >= 1:
		$AnimatedSprite.flip_h = true
	if velocity.x <= -1:
		$AnimatedSprite.flip_h = false
	
	if velocity.length() > 0:
		$AnimatedSprite.animation = "walk"
	else:
		$AnimatedSprite.animation = "idle"
