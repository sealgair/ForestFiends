extends "Player.gd"

var base_gravity
var from_touches = Vector2(0, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	base_gravity = gravity


func get_species():
	return "Spid"
	
func get_animation():
	var pressed = axes_pressed()
	var touches = touching_sides()
	if is_attacking():
		return "attack"
	elif touches.length() == 0:
		return "jump"
	elif touches.x != 0 and touches.y != 0:
		return "corner"
	elif pressed.x != 0 and touches.y != 0:
		return "walk"
	elif pressed.y != 0 and touches.x != 0:
		return "walk"
	else:
		return "idle"

func touching_sides():
	var touches = Vector2()
	if $RightTouch.get_overlapping_bodies().size() > 0:
		touches.x = 1
	elif $LeftTouch.get_overlapping_bodies().size() > 0:
		touches.x = -1
	
	if $TopTouch.get_overlapping_bodies().size() > 0:
		touches.y = -1
	elif $BottomTouch.get_overlapping_bodies().size() > 0:
		touches.y = 1
	
	return touches


func special_pressed():
	var touches = touching_sides()
	if touches.length() != 0:
		jumping = true
		velocity += jump_speed  * touches
		if touches.y == 0:
			velocity.y += jump_speed/2


func move(x,y):
	gravity = base_gravity
	var touches = touching_sides()
	if touches.length() != 0:
		gravity = 0
	
	$AnimatedSprite.rotation_degrees = 0
	to_velocity = velocity + touches * 10
	
	if touches.x != 0:
		$AnimatedSprite.rotation_degrees = 90
		to_velocity.y = y * run_speed

		$AnimatedSprite.flip_v = touches.x > 0
		if y != 0:
			$AnimatedSprite.flip_h = y > 0
	
	if touches.y != 0:
		to_velocity.x = x * run_speed
		
		$AnimatedSprite.flip_v = touches.y < 0
		if x != 0:
			$AnimatedSprite.flip_h = x > 0
	
	if touches.x != 0 and touches.y != 0:
		# corner
		if from_touches.x != 0:
			$AnimatedSprite.rotation_degrees = 90
			$AnimatedSprite.flip_v = touches.x > 0
			$AnimatedSprite.flip_h = touches.y > 0
		else:
			$AnimatedSprite.rotation_degrees = 0
			$AnimatedSprite.flip_h = touches.x > 0
			$AnimatedSprite.flip_v = touches.y < 0
	elif touches.length() != 0:
		# not in corner
		from_touches = touches * 1 # copy

