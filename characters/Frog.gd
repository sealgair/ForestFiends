extends "Player.gd"

var jump_time = 0
var max_jump = -300
var look_angle = 0
var look_change = 0
var texture = preload("res://art/forg.png")

func init(start_pos, the_tilemap):
	run_speed = 150
	jump_speed = -60
	attack_range = 16
	jump_height = 3
	jump_dist = 3
	.init(start_pos, the_tilemap)
	attack_anim = "tongue"
	var image = texture.get_data()
	image.lock()
	$Tongue.default_color = image.get_pixel(palette, 3)
	image.unlock()


func get_species():
	return "Frog"


func special_pressed():
	.special_pressed()
	if jumping:
		jump_time = 0.2


func make_attack():
	var instance = .make_attack()
	instance.get_node("AnimatedSprite").material.set_shader_param("palette", palette)
	return instance


func move(x, y):
	to_velocity = Vector2()
	if x != 0:
		$AnimatedSprite.flip_h = x > 0
	if jumping:
		to_velocity = velocity * 1
		to_velocity.x = run_speed * facing()
		if is_special_pressed() and jump_time > 0:
			velocity.y += jump_speed
			velocity.y = max(max_jump, velocity.y)
	
	look_change = -y


func moved(delta):
	.moved(delta)
	look_angle = clamp(look_angle + TAU/4 * delta * look_change, 0, TAU/4)


func _process(delta):
	._process(delta)
	if is_on_floor():
		jump_time = 0
	else:
		jump_time = max(jump_time - delta, 0)
	
	var ret = Vector2(-attack_range, 0)
	ret = ret.rotated(look_angle)
	if $AnimatedSprite.flip_h:
		ret *= Vector2(-1, 1)
	$Reticle.transform.origin = ret
		
	var an = attack_node.get_ref()
	$Tongue.visible = an != null
	if an:
		var l = easeoutback(an.life/an.live)
		ret = ret * l * 2
		an.transform.origin = ret
		$Tongue.set_point_position(1, ret)

func should_attack(enemy):
	var dist = position - enemy.position
	var angle = look_angle - atan2(dist.y, dist.x)
	input.press_axis(Vector2(0, angle))
	if abs(angle) < TAU/8:
		return dist.length() < attack_range

func move_toward_point(point):
	.move_toward_point(point)
	if position.y - point.y <= 4 or is_on_floor():
		# dont' jump if we need to go down
		input.press('special')
