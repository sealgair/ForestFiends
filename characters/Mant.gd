extends "Player.gd"

var poised = false
var poise_timer = 0
var poise_time = 0.5

var opacity = 1
var fade_time = 0.3
var died = false

func _ready():
	super()
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
			hiding = false
			super.make_attack()
			special_timeout = special_wait
		poise_timer = 0

func special_pressed():
	if revive_countdown <= 0:
		hiding = not hiding

func move(dir):
	if poised:
		to_velocity.x = 0
		if dir.x != 0:
			$AnimatedSprite2D.flip_h = dir.x > 0
	else:
		super.move(dir)
		if hiding and velocity.x != 0:
			to_velocity.x *= 0.1
	

func get_animation():
	if poised:
		if poise_timer <= 0:
			return "poised"
		else:
			return "poising"
	return super.get_animation()

func die():
	super.die()
	poise_timer = 0
	hiding = false
	poised = false
	died = true

func _process(delta):
	super(delta)
	if hiding:
		var min_opacity = 0
		if not poised and axes_pressed().x != 0:
			min_opacity = 0.2
		opacity = max(min_opacity, opacity - delta / fade_time)
	else:
		opacity = min(1, opacity + delta / fade_time)
	$AnimatedSprite2D.modulate = Color(1,1,1,opacity)
	
	if poised:
		poise_timer = max(0, poise_timer - delta)

func init_brain():
	var data = super.init_brain()
	data.state = 'recon'
	data.attack_accuracy = 1
	data.recon_time = 1
	data.recon = data.recon_time
	data.hide_time = randf() * 8 + 3
	data.hiding = 0
	data.tracked_tiles = {}
	data.hiding_spot = null
	return data

func reset_brain():
	super()
	brain.target = null
	brain.recon = brain.recon_time
	brain.tracked_tiles = {}
	brain.hide_time = randf() * 10 + 10
	brain.hiding_spot = null
	brain.hiding = 0

func think(delta):
	if not is_instance_valid(brain.target) or (brain.target and brain.target.dead):
		brain.target = closest_enemy()
		brain.path = null
		
	var should_hide = false
	if brain.recon > 0:
		for enemy in enemies:
			var pos = Global.round2(enemy.position / self.cell_size) * self.cell_size
			var players = brain.tracked_tiles.get(pos, [])
			players.append(enemy.order)
			brain.tracked_tiles[pos] = players
		brain.recon -= delta
		var safe = safe_spot()
		if safe:
			var path = pathfinder.path_between(position, safe)
			follow_path(path)
		wander(delta)
	else:
		brain.wander = 0 # always start fresh
		if not hiding:
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
					should_hide = true
					brain.hiding = 0
				else:
					follow_path(path)
		else:
			should_hide = true # keep hiding
			# if we've stopped somewhere slightly off of our hiding spot, let's stick around
			brain.hiding_spot == position
			brain.target = closest_enemy()
			if brain.target:
				var target_dir = brain.target.position - position
				if sign(target_dir.x) != facing():
					input.press_axis(Vector2(sign(target_dir.x), 0))
				if poise_timer <= 0 and should_attack(brain.target):
					if randf() <= brain.attack_accuracy:
						input.release('attack')
						reset_brain()
						should_hide = false
				else:
					input.hold('attack')
			brain.hiding += delta
			if brain.hiding >= brain.hide_time:
				input.release('attack')
				reset_brain()
				should_hide = false
	if hiding != should_hide:
		input.press('special')
