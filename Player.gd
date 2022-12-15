extends KinematicBody2D

export (int) var run_speed = 100
export (int) var jump_speed = -450
export (int) var gravity = 1200

var screen_size
signal hit

var velocity = Vector2()
var jumping = false
var size = Vector2(16, 16) # todo: dynamic

func _ready():
	screen_size = get_viewport_rect().size

func get_input():
	velocity.x = 0
	if Input.is_action_pressed("move_right"):
		velocity.x += run_speed
		$AnimatedSprite.flip_h = true
	if Input.is_action_pressed("move_left"):
		velocity.x -= run_speed
		$AnimatedSprite.flip_h = false
		
	var jump = Input.is_action_just_pressed('move_special')
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
