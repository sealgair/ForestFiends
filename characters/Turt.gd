extends "Player.gd"

var defending = false

func _ready():
	run_speed = 60
	$Head.material.set_shader_param("palette", palette)
	attack_anim = "none"


func get_species():
	return "Turt"

func get_animation():
	if defending:
		return "defend"
	return .get_animation()


func get_input(delta):
	.get_input(delta)
	if not Input.is_action_pressed(inputs['special']):
		defending = false
	
	
func special():
	if not defending:
		defending = true
		$AnimatedSprite.play("defend")

func walk(delta):
	if not defending:
		return .walk(delta)
	else:
		velocity.x = 0	

func is_vulnerable():
	return .is_vulnerable() and not defending

func _process(delta):
	._process(delta)
	$Head.flip_h = $AnimatedSprite.flip_h
	var an = attackNode.get_ref()
	$Head.visible = not defending and not dead
	$Head.animation = "idle"
	if an:
		var xoff = easeoutback(an.life/an.live) * 10
		if xoff > 4:
			$Head.animation = "attack"
		if not $Head.flip_h:
			xoff *= -1
		$Head.transform.origin.x = xoff
		an.transform.origin.x = xoff * 2.1
	else:
		$Head.transform.origin.x = 0
