extends "Player.gd"


var poised = false
var poise_timer = 0
var poise_time = 0.5

var hidden = false
var opacity = 1
var fade_time = 0.3

func _ready():
	attack_anim = "none"


func get_species():
	return "Mant"


func make_attack():
	if not poised:
		poised = true
		poise_timer = poise_time


func attack_released():
	if poised:
		poised = false
		if poise_timer <= 0:
			.make_attack()
			hidden = false
		poise_timer = 0


func special_pressed():
	hidden = not hidden


func move(x, y):
	if poised:
		velocity.x = 0
		if x != 0:
			$AnimatedSprite.flip_h = x > 0
	else:
		.move(x, y)
		if hidden and velocity.x != 0:
			velocity.x *= 0.1
	

func get_animation():
	if poised:
		if poise_timer <= 0:
			return "poised"
		else:
			return "poising"
	return .get_animation()


func _process(delta):
	._process(delta)
	
	if hidden:
		var min_opacity = 0
		if velocity.x != 0 or velocity.y != 0:
			min_opacity = 0.2
		opacity = max(min_opacity, opacity - delta / fade_time)
	else:
		opacity = min(1, opacity + delta / fade_time)
	$AnimatedSprite.modulate = Color(1,1,1,opacity)
	
	if poised:
		poise_timer = max(0, poise_timer - delta)
