extends "Player.gd"

var defending = false
var defend_cooldown = 1

func _ready():
	run_speed = 60
	accelerate = 6
	$Head.material.set_shader_param("palette", palette)
	attack_anim = "none"
	$DefendCooldown.stop()


func get_species():
	return "Turt"


func get_animation():
	if defending:
		return "defend"
	return .get_animation()


func special_pressed():
	if not defending and $DefendCooldown.time_left <= 0:
		defending = true
		$AnimatedSprite.play("defend")
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
	return .is_vulnerable() and not defending


func _process(delta):
	._process(delta)
	$Head.flip_h = $AnimatedSprite.flip_h
	var an = attack_node.get_ref()
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
