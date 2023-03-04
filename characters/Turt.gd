extends "Player.gd"

var defending = false
var defend_cooldown = 1

func _ready():
	super()
	run_speed = 60
	accelerate = 6
	attack_anim = "none"
	$DefendCooldown.stop()

func get_species():
	return "Turt"

func get_long_species():
	return "Turtle"

func pronouns():
	return ['he', 'him', 'his', 'his']

func get_animation():
	if defending:
		return "defend"
	return super.get_animation()

func special_pressed():
	if not defending and $DefendCooldown.time_left <= 0:
		defending = true
		$AnimatedSprite2D.play("defend")
		$DefendTimer.start()

func special_released():
	if defending:
		defending = false
		var timer_used = 1 - ($DefendTimer.time_left / $DefendTimer.wait_time)
		$DefendCooldown.start(defend_cooldown * timer_used)
		$DefendTimer.stop()

func is_mobile():
	return not defending

func is_vulnerable():
	return super.is_vulnerable() and not defending

func _process(delta):
	super(delta)
	$AnimatedSprite2D/Head.flip_h = $AnimatedSprite2D.flip_h
	var an = attack_node.get_ref()
	$AnimatedSprite2D/Head.visible = not defending and not dead
	$AnimatedSprite2D/Head.animation = "idle"
	if axes_pressed().x != 0 or not is_on_floor():
		$AnimatedSprite2D/Head.animation = "walk"
	if an:
		var xoff = easeoutback(an.life/an.live) * 10
		if xoff > 4:
			$AnimatedSprite2D/Head.animation = "attack"
		if not $AnimatedSprite2D/Head.flip_h:
			xoff *= -1
		$AnimatedSprite2D/Head.transform.origin.x = xoff
		an.transform.origin.x = xoff * 2.1
	else:
		$AnimatedSprite2D/Head.transform.origin.x = 0
		if velocity.x == 0:
			$AnimatedSprite2D/Head.animation = "idle"

func _on_DefendTimer_timeout():
	defending = false
	$DefendCooldown.start(defend_cooldown)

func _on_DefendCooldown_timeout():
	if is_special_pressed():
		special_pressed()

func should_attack(enemy):
	return abs(position.x - enemy.position.x) < 18

func should_special(enemy, path=[]):
	return abs(position.x - enemy.position.x) < 8 and randf() <= brain.special_accuracy
