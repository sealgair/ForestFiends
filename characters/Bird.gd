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
	return "Bird"


func special_pressed():
	if flaps <= max_flaps and flapped <= 0:
		flaps += 1
		flapped = 0.3
		velocity.y = flap_speed

func moved(delta):
	.moved(delta)
	if is_attacking():
		if is_on_floor():
			to_velocity.x = 0
		else:
			to_velocity.x = dive_speed
			if not $AnimatedSprite.flip_h:
				to_velocity.x *= -1


func make_attack():
	var instance = .make_attack()
	if instance and not is_on_floor():
		instance.transform.origin.y += 8
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