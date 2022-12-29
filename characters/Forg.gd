extends "Player.gd"

var jump_time = 0
var max_jump = -300


func _ready():
	._ready()
	run_speed = 150
	jump_speed = -50
	attack_scene = preload("res://characters/ForgAttack.tscn")


func get_species():
	return "Forg"


func special():
	if is_on_floor():
		jumping = true
		jump_time = 0.2
		velocity.y = jump_speed


func walk():
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


func _process(delta):
	._process(delta)
	if is_on_floor():
		jump_time = 0
	else:
		jump_time = max(jump_time - delta, 0)
		
	var an = attackNode.get_ref()
	$Tongue.visible = an != null
	if an:
		var x = easeoutback(an.life/an.live) * 32
		if $AnimatedSprite.flip_h:
			x *= -1
		an.transform.origin.x = x
		$Tongue.set_point_position(1, Vector2(-x, 0))


func easeoutback(t, p=4):
	return 1-pow(2*(t-.5), p)
