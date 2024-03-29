extends "Player.gd"

var dashing = 0
var dash_time = 0.5
var dash_speed = run_speed * 2


func init(start_pos, the_tilemap):
	jump_speed = -200
	jump_dist = 3
	super.init(start_pos, the_tilemap)
	

func get_species():
	return "Shrew"

func pronouns():
	return ['he', 'him', 'his', 'his']

func attack_pressed():
	if dashing <= 3*dash_time/4:
		# no attack in first quarter of dash
		super.attack_pressed()


func special_pressed():
	if is_on_floor() and dashing <= 0:
		super.special_pressed()
		dashing = dash_time


func moved(delta):
	super.moved(delta)
	if dashing > 0:
		var dash = dash_speed
		if velocity.x == 0:
			if not $AnimatedSprite2D.flip_h:
				dash *= -1
		else:
			dash *= facing()
		to_velocity.x = dash

func _process(delta):
	var was_dashing = dashing > 0
	dashing = max(dashing-delta, 0)
	if is_on_floor():
		dashing = 0
	if was_dashing and dashing <= 0:
		# flip and attack at the end of the dash
		if input.direction_pressed().x == 0:
			to_velocity.x = 0
			$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
	
	super(delta)


func should_special(enemy, path=[]):
	if randf() <= brain.special_accuracy:
		var dv = Global.abs2(position - enemy.position)
		if dv.y < size.y:
			if dv.x < size.x*4 and dv.x > size.x:
				return true
	return false
