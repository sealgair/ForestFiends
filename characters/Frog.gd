extends "Player.gd"

var jump_time = 0
var max_jump = -300
var look_angle = 0
var look_change = 0

func _ready():
	._ready()
	run_speed = 150
	jump_speed = -60
	attack_anim = "tongue"


func get_species():
	return "Frog"


func special_pressed():
	.special_pressed()
	if jumping:
		jump_time = 0.2


func move(x, y):
	to_velocity = Vector2()
	if x != 0:
		$AnimatedSprite.flip_h = x > 0
	if jumping:
		to_velocity = velocity * 1
		to_velocity.x = run_speed * facing()
		if is_special_pressed() and jump_time > 0:
			velocity.y += jump_speed
			velocity.y = max(max_jump, velocity.y)
	
	look_change = -y


func moved(delta):
	.moved(delta)
	look_angle = clamp(look_angle + TAU/4 * delta * look_change, 0, TAU/4)


func _process(delta):
	._process(delta)
	if is_on_floor():
		jump_time = 0
	else:
		jump_time = max(jump_time - delta, 0)
	
	var ret = Vector2(-16, 0)
	ret = ret.rotated(look_angle)
	if $AnimatedSprite.flip_h:
		ret *= Vector2(-1, 1)
	$Reticle.transform.origin = ret
		
	var an = attackNode.get_ref()
	$Tongue.visible = an != null
	if an:
		var l = easeoutback(an.life/an.live)
		ret = ret * l * 2
		an.transform.origin = ret
		$Tongue.set_point_position(1, ret)
