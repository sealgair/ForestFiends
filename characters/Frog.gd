extends "Player.gd"

var jump_time = 0
var max_jump = -300
var look_angle = 0
var look_change = 0
var texture = preload("res://art/frog16.png")

func init(start_pos, the_tilemap):
	run_speed = 150
	jump_speed = -60
	attack_range = 16
	attack_range_v = 16
	jump_height = 3
	jump_dist = 3
	super.init(start_pos, the_tilemap)
	attack_anim = "tongue"
	var image = texture.get_image()
	false # image.lock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	$Tongue.default_color = image.get_pixel(palette, 5)
	false # image.unlock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

func get_species():
	return "Frog"

func pronouns():
	return ['she', 'her', 'her', 'hers']

func special_pressed():
	super.special_pressed()
	if jumping:
		jump_time = 0.2

func make_attack():
	var instance = super.make_attack()
	instance.get_node("AnimatedSprite2D").material.set_shader_parameter("palette", palette)
	return instance

func move(dir):
	to_velocity = Vector2()
	if dir.x != 0:
		$AnimatedSprite2D.flip_h = dir.x > 0
	if jumping:
		to_velocity = velocity * 1
		to_velocity.x = run_speed * facing()
		if is_special_pressed() and jump_time > 0:
			velocity.y += jump_speed
			velocity.y = max(max_jump, velocity.y)
	
	look_change = -dir.y


func moved(delta):
	super.moved(delta)
	look_angle = clamp(look_angle + TAU/4 * delta * look_change, 0, TAU/4)


func _process(delta):
	super(delta)
	if is_on_floor():
		jump_time = 0
	else:
		jump_time = max(jump_time - delta, 0)
	
	var ret = Vector2(-attack_range, 0)
	ret = ret.rotated(look_angle)
	if $AnimatedSprite2D.flip_h:
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

func move_toward_point(point, final=false):
	super.move_toward_point(point)
	if position.y - point.y > 0 or is_on_ceiling():
		# let go of jump if we need to go down, or our head touched the roof
		input.release('special')
	elif is_on_floor():
		input.hold('special')
