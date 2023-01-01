extends "Player.gd"

var dashing = 0
var dash_speed = run_speed * 2


# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	jump_speed = -200
	

func get_species():
	return "Shrew"


func attack_pressed():
	if dashing <= 0:
		# no attack while dashing
		.attack_pressed()


func special_pressed():
	if is_on_floor() and dashing <= 0:
		.special_pressed()
		dashing = 0.5


func moved(delta):
	.moved(delta)
	if dashing > 0:
		var dash = dash_speed
		if velocity.x == 0:
			if not $AnimatedSprite.flip_h:
				dash *= -1
		else:
			dash *= sign(velocity.x)
		velocity.x = dash

func _process(delta):
	var was_dashing = dashing > 0
	dashing = max(dashing-delta, 0)
	if is_on_floor():
		dashing = 0
	if was_dashing and dashing <= 0:
		# flip and attack at the end of the dash
		if Input.get_axis(inputs['left'], inputs['right']) == 0:
			velocity.x = 0
			$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		attack_pressed()
	
	._process(delta)
