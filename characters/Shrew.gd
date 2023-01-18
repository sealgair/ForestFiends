extends "Player.gd"

var dashing = 0
var dash_time = 0.5
var dash_speed = run_speed * 2


# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	jump_speed = -200
	

func get_species():
	return "Shrew"


func attack_pressed():
	if dashing <= 3*dash_time/4:
		# no attack in first quarter of dash
		.attack_pressed()


func special_pressed():
	if is_on_floor() and dashing <= 0:
		.special_pressed()
		dashing = dash_time


func moved(delta):
	.moved(delta)
	if dashing > 0:
		var dash = dash_speed
		if velocity.x == 0:
			if not $AnimatedSprite.flip_h:
				dash *= -1
		else:
			dash *= facing()
		to_velocity.x = dash

func _process(delta):
	var was_dashing = dashing > 0
	dashing = max(dashing-delta, 0)
	if is_on_floor():
		dashing = 0
	if was_dashing and dashing <= 0:
		# flip and attack at the end of the dash
		if input.direction_pressed().x == 0:
			to_velocity.x = 0
			$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
	
	._process(delta)
