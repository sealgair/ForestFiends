extends KinematicBody2D

export (int) var player = 1
export (int) var palette = null

var inputs = {}
var run_speed = 100
var jump_speed = -450
var gravity = 1200

var screen_size
signal hit

var velocity = Vector2()
var jumping = false
var size = Vector2(16, 16) # todo: dynamic
var attackNode = weakref(null)

func _ready():
	screen_size = get_viewport_rect().size
	# button mappings
	inputs['right'] = "move_right{p}".format({'p': player}) 
	inputs['left'] = "move_left{p}".format({'p': player}) 
	inputs['special'] = "move_special{p}".format({'p': player}) 
	inputs['attack'] = "move_attack{p}".format({'p': player})
	if palette == null:
		palette = player - 1
	$AnimatedSprite.material.set_shader_param("palette", palette)

func special():
	if is_on_floor():
		jumping = true
		velocity.y = jump_speed

func attack():
	var instance = load("res://Attack.tscn").instance()
	instance.set_name("attack")
	add_child(instance)
	attackNode = weakref(instance)
	$AnimatedSprite.play("attack")

func get_input():
	velocity.x = 0
	if Input.is_action_pressed(inputs['right']):
		velocity.x += run_speed
		$AnimatedSprite.flip_h = true
	if Input.is_action_pressed(inputs['left']):
		velocity.x -= run_speed
		$AnimatedSprite.flip_h = false
		
	if Input.is_action_just_pressed(inputs['special']):
		special()
		
	if Input.is_action_just_pressed(inputs['attack']):
		attack()

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
		
	var an = attackNode.get_ref()
	if an:
		$AnimatedSprite.animation = "attack"
		an.get_node("AnimatedSprite").flip_h = $AnimatedSprite.flip_h
		an.transform.origin.x = abs(an.transform.origin.x)
		if not $AnimatedSprite.flip_h:
			an.transform.origin.x *= -1
	elif not is_on_floor():
		$AnimatedSprite.animation = "jump"
	elif velocity.length() > 0:
		$AnimatedSprite.animation = "walk"
	else:
		$AnimatedSprite.animation = "idle"
