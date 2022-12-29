extends "Player.gd"


func _ready():
	run_speed = 60
	$Head.material.set_shader_param("palette", palette)
	attack_anim = "none"


func get_species():
	return "Trut"


func _process(delta):
	._process(delta)
	$Head.flip_h = $AnimatedSprite.flip_h
	var an = attackNode.get_ref()
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
