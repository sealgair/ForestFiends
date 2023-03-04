extends "Player.gd"

var flap_speed = -150
var dive_speed = 80
var flaps = 0
var max_flaps = 3
var flapped = 0.0


func init(start_pos, the_tilemap):
	gravity *= .25
	special_wait = 0.1
	jump_height = 3
	jump_dist = 4
	attack_anim = "peck"
	super.init(start_pos, the_tilemap)

func get_species():
	return "Bird"

func pronouns():
	return ['he', 'him', 'his', 'his']

func special_pressed():
	if flaps <= max_flaps and flapped <= 0:
		flaps += 1
		flapped = 0.3
		velocity.y = flap_speed

func moved(delta):
	super.moved(delta)
	if is_attacking():
		if is_on_floor():
			to_velocity.x = 0
		else:
			to_velocity.x = dive_speed
			if not $AnimatedSprite2D.flip_h:
				to_velocity.x *= -1

func make_attack():
	var instance = super.make_attack()
	if instance and not is_on_floor():
		instance.transform.origin.y += 8
		velocity.y = dive_speed

func get_animation():
	var anim_name = super.get_animation()
	if anim_name == "attack" and not is_on_floor():
		return "dive"
	elif anim_name == "jump" and flapped > 0:
		return "flap"
	return anim_name

func _process(delta):
	if is_on_floor():
		flaps = 0
	super._process(delta)
	flapped = max(flapped-delta, 0)

func should_jump(enemy, path=[]):
	# should jump again only at the top of previous jump 
	#  (about to switch from rising to falling)
	return velocity.y > -1 and super.should_jump(enemy, path)

func should_attack(enemy):
	if self.is_on_floor():
		return super.should_attack(enemy)
	else:
		var dist = position - enemy.position
		return dist.y > 0 and dist.y < 24 and abs(dist.x) < 16
