extends "Player.gd"

var jump_time = 0
var max_jump = -300
var look_angle = 0

func _ready():
	._ready()
	run_speed = 150
	jump_speed = -50
	attack_anim = "tongue"


func get_species():
	return "Frog"


func special():
	if is_on_floor():
		jumping = true
		jump_time = 0.2
		velocity.y = jump_speed


func walk(delta):
	# TODO: figure out slipping on slime
	self.velocity.x = 0
	var x = Input.get_axis(inputs['left'], inputs['right'])
	if x != 0:
		$AnimatedSprite.flip_h = x > 0
	if jumping:
		var f = 1
		if not $AnimatedSprite.flip_h:
			f = -1
		velocity.x += f * run_speed
		if Input.is_action_pressed(inputs['special']) and jump_time > 0:
			velocity.y += jump_speed
			velocity.y = max(max_jump, velocity.y)


func get_input(delta):
	.get_input(delta)
	var y = Input.get_axis(inputs['down'], inputs['up'])
	look_angle = clamp(look_angle + TAU/4 * delta * y, 0, TAU/4)


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
