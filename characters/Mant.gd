extends "Player.gd"

var poised = false
var poise_timer = 0
var poise_time = 0.5

var opacity = 1
var fade_time = 0.3
var died = false

func _ready():
	special_wait = 1.5
	attack_anim = "slash"

func get_species():
	return "Mant"

func get_long_species():
	return "Mantis"

func pronouns():
	return ['she', 'her', 'her', 'hers']

func make_attack():
	if not poised:
		poised = true
		poise_timer = poise_time


func attack_released():
	if poised:
		poised = false
		if poise_timer <= 0:
			hidden = false
			.make_attack()
			special_timeout = special_wait
		poise_timer = 0

func special_pressed():
	if revive_countdown <= 0:
		hidden = not hidden

func move(dir):
	if poised:
		to_velocity.x = 0
		if dir.x != 0:
			$AnimatedSprite.flip_h = dir.x > 0
	else:
		.move(dir)
		if hidden and velocity.x != 0:
			to_velocity.x *= 0.1
	

func get_animation():
	if poised:
		if poise_timer <= 0:
			return "poised"
		else:
			return "poising"
	return .get_animation()

func die():
	.die()
	poise_timer = 0
	hidden = false
	poised = false
	died = true

func _process(delta):
	if hidden:
		var min_opacity = 0
		if not poised and axes_pressed().x != 0:
			min_opacity = 0.2
		opacity = max(min_opacity, opacity - delta / fade_time)
	else:
		opacity = min(1, opacity + delta / fade_time)
	$AnimatedSprite.modulate = Color(1,1,1,opacity)
	
	if poised:
		poise_timer = max(0, poise_timer - delta)

func init_brain():
	var data = .init_brain()
	data.recon_time = 1
	data.recon = data.recon_time
	data.hide_time = 10
	data.hiding = 0
	data.tracked_tiles = {}
	data.hiding_spot = null
	return data

func reset_brain():
	.reset_brain()
	brain.recon = brain.recon_time
	brain.tracked_tiles = {}
	brain.hiding_spot = null
	brain.hiding = 0

func think(delta):
	if not is_instance_valid(brain.target):
		brain.target = null
	var hide = false
	if brain.recon > 0 or revive_countdown > 0:
		for enemy in enemies:
			var pos = Global.round2(enemy.position / tilemap.cell_size) * tilemap.cell_size
			var players = brain.tracked_tiles.get(pos, [])
			players.append(enemy.order)
			brain.tracked_tiles[pos] = players
		brain.recon -= delta
		var safe = safe_spot()
		if safe:
			var path = pathfinder.path_between(position, safe)
			follow_path(path)
	else:
		if not hidden:
			if poised:
				input.release('attack')
			if brain.hiding_spot == null:
				# find the closest tile that's had an enemy in it
				var closest = null
				for pos in brain.tracked_tiles.keys():
					var dist = pathfinder.distance_between(position, pos)
					if dist > 32 and (closest == null or closest > dist):
						closest = dist
						brain.hiding_spot = pos
			if brain.hiding_spot != null:
				var path = pathfinder.path_between(position, brain.hiding_spot)
				if pathfinder.path_distance(path) < 8:
					hide = true
					brain.hiding = 0
				else:
					follow_path(path)
		else:
			if brain.target == null or brain.target.dead:
				brain.target = closest_enemy()
			if brain.target:
				var target_dir = brain.target.position - position
				if poise_timer > 0 and should_attack(brain.target):
					if randf() <= brain.attack_accuracy:
						input.release('attack')
					reset_brain()
				else:
					input.hold('attack')
					if sign(target_dir.x) != facing():
						input.press_axis(Vector2(sign(target_dir.x), 0))
			brain.hiding += delta
			if brain.hiding >= brain.hide_time:
				input.release('attack')
				reset_brain()
	if hidden != hide:
		input.press('special')
