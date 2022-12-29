extends "Player.gd"

var flap_speed = -150
var dive_speed = 80
var flaps = 0
var max_flaps = 3
var flapped = 0.0


func _ready():
	._ready()
	gravity *= .25


func get_species():
	return "Brid"


func special():
	if flaps <= max_flaps and flapped <= 0:
		flaps += 1
		flapped = 0.3
		velocity.y = flap_speed

func get_input(delta):
	.get_input(delta)
	if is_attacking():
		if is_on_floor():
			velocity.x = 0
		else:
			velocity.x = dive_speed
			if not $AnimatedSprite.flip_h:
				velocity.x *= -1

func attack():
	.attack()
	if not is_on_floor():
		var an = attackNode.get_ref()
		an.transform.origin.y += 8
		velocity.y = dive_speed

func get_animation():
	var anim_name = .get_animation()
	if anim_name == "attack" and not is_on_floor():
		return "dive"
	elif anim_name == "jump" and flapped > 0:
		return "flap"
	return anim_name


func _process(delta):
	if is_on_floor():
		flaps = 0
	._process(delta)
	flapped = max(flapped-delta, 0)
