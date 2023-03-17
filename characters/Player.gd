extends CharacterBody2D

const PlayerInput = preload("res://main/PlayerInput.gd")
const ComputerInput = preload("res://main/ComputerInput.gd")
const attack_scene = preload("res://characters/Attack.tscn")
const Spore = preload("res://characters/Spore.tscn")
var PlayerPath = preload("res://brain/PlayerPath.gd")

@export var order: int = 1
@export var palette: int
@export var computer: bool = false

var ate = 0
var fed = 0
var score = 0
var time = 0
var distance = 0
var distance_delta = 0
var attacks = 0
var specials = 0

var input
var run_speed = 100
var jump_speed = -450
var base_gravity = Vector2(0, 1200)
var gravity = base_gravity
var accelerate = 10
var decelerate = 20

var jump_height = 0
var jump_dist = 0
var attack_range = 12

var attack_wait = 0.1
var attack_timeout = 0
var attack_offset = Vector2(16,0)
var revive_countdown = 0
var revive_time = 2

var special_wait = 1
var special_timeout = 0

var screen_size: Vector2
var cell_size: Vector2
signal made_hit
signal respawn(player)
signal make_slime(position, palette)
signal make_web(start, end, player)

var to_velocity = Vector2()
var jumping = false
var size = Vector2(16, 16) # todo: dynamic
var attack_node = weakref(null)
var dead = false
var poisoned_by = null
var spore = null
var slimed = 0
var slime_time = 2
var webs = []
var web_points = {}
var hiding = false

var attack_anim = "bite"
var enemies = []

var tilemap
var pathfinder

func _ready():
	screen_size = get_viewport_rect().size
	cell_size = Vector2(tilemap.tile_set.tile_size)
	set_computer(computer)
	if palette == null:
		palette = order - 1
	$AnimatedSprite2D.material.set_shader_parameter("palette", palette)
	$AnimatedSprite2D.play("idle")
	

func make_enemies(all_players):
	for player in all_players:
		if player != self:
			enemies.append(player)

func get_enemies():
	# includes mushrooms
	var list = []
	for enemy in enemies:
		if "mushrooms" in enemy:
			list.append_array(enemy.mushrooms.values())
		else:
			list.append(enemy)
	return list

func init(start_pos, the_tilemap):
	position = start_pos + size /2
	tilemap = the_tilemap
	pathfinder = PlayerPath.new(self, tilemap)
	ate = 0
	fed = 0
	$PathVis.default_color = [
		Color(0,0,1),
		Color(1,0,0),
		Color(0,1,0),
		Color(1,1,0),
	][order-1]

func get_species():
	return "Player"

func get_long_species():
	return get_species()

func get_short_name():
	return Global.aminal_names[get_species()]

func get_long_name():
	return "%s the %s" % [get_short_name(), get_long_species()]

func pronouns():
	return ['they', 'them', 'their', 'theirs']

func do_make_slime(_position, _palette=0):
	pass # to implement in slug

func set_computer(is_computer):
	computer = is_computer
	if computer:
		set_input(ComputerInput.new(order))
	else:
		set_input(PlayerInput.new(order))

func set_input(new_input):
	if input != null:
		input.queue_free()
	input = new_input
	add_child(input)
	input.set_mappings({
		'attack': 'a',
		'special': 'b'
	})

func special_pressed():
	if is_on_floor():
		jumping = true
		velocity.y = jump_speed
		specials += 1

func special_released():
	pass

func is_special_pressed():
	return input.is_pressed('special')

func attack_pressed():
	make_attack()

func make_attack():
	attacks += 1
	var instance = attack_scene.instantiate()
	instance.attacker = self
	instance.transform.origin += attack_offset
	instance.set_name("attack")
	instance.configure(attack_anim)
	add_child(instance)
	attack_node = weakref(instance)
	$AnimatedSprite2D.play("attack")
	return instance

func attack_released():
	pass

func is_attack_pressed():
	return input.is_pressed('attack')

func is_mobile():
	return true

func facing():
	return facing2().x

func facing2():
	var result = Vector2(-1, 1)
	if $AnimatedSprite2D.flip_h:
		result.x = 1
	if $AnimatedSprite2D.flip_v:
		result.y = -1
	return result

func axes_pressed():
	if is_mobile():
		return input.direction_pressed()
	else:
		return Vector2(0,0)

var infected_target = null
var infected_target_reset = 3
func infected_move(dir):
	infected_target_reset = max(infected_target_reset-1, 0)
	if spore != null:
		if infected_target == null or infected_target_reset <= 0:
			infected_target = closest_enemy({'fungus': false}) # not mushrooms
			infected_target_reset = 3
		if infected_target:
			var path = pathfinder.path_between(position, infected_target.position)
			var next = point_on_path(path)
			if next != null:
				next = infected_target.position
				var ndir = Global.sign2(next - position)
				if not spore.grown:
					ndir *= -1
				var ir = infect_rate()
				dir = ndir * ir + dir * (1-ir)
	return dir

func move(dir):
	to_velocity = velocity * 1 # copy
	to_velocity.x = dir.x * run_speed
	
	if dir.x != 0:
		$AnimatedSprite2D.flip_h = dir.x > 0

# warning-ignore:unused_argument
func moved(_delta):
	pass

func infect_rate():
	if spore == null:
		return 0
	else:
		return spore.infect_rate()

func handle_input(delta):
	if computer and input.override():
		set_input(PlayerInput.new(order))
		computer = false
	
	var axes = axes_pressed()
	axes = infected_move(axes)
	move(axes)
	moved(delta)
	
	# can't attack / special if webbed
	if webs.size() <= 0:
		if input.is_just_pressed('special'):
			if special_timeout <= 0:
				special_timeout = special_wait
				special_pressed()
		if input.is_just_released('special'):
			special_released()
			
		if input.is_just_pressed('attack'):
			if attack_timeout <= 0:
				attack_timeout = attack_wait
				if randf() > infect_rate():
					attack_pressed()
		if input.is_just_released('attack'):
			attack_released()

func track_distance(amount):
	distance_delta = amount
	distance += amount

func up_dir():
	return Vector2(0, -1)

func _physics_process(delta):
	if jumping and is_on_floor():
		jumping = false
	if dead:
		to_velocity = Vector2()
	else:
		if computer:
			think(delta)
		handle_input(delta)
	var dv = to_velocity - velocity
	var rate = accelerate
	if slimed:
		rate /= 10
		if axes_pressed().x == 0:
			rate /= 2
	elif axes_pressed().x == 0:
		rate = decelerate
	velocity += dv * delta * rate
	if webs.size() > 0:
		var points = []
		for web in webs:
			points.append(web_points[web.get_instance_id()])
		var webbed = Global.center(points)
		velocity = (webbed - position) * run_speed
	else:
		if dead:
			velocity = base_gravity * delta
		else:
			velocity += gravity * delta
	var before = position
	set_velocity(velocity)
	set_up_direction(up_dir())
	move_and_slide()
	velocity = velocity
	track_distance((position - before).length())
	
	# use transform not position so as not to break physics
	var screenwrap = Vector2(
		wrapf(transform.origin.x, 0, screen_size.x),
		wrapf(transform.origin.y, 0, screen_size.y)
	) - transform.origin
	if screenwrap.length() > 0:
		wrap_screen(screenwrap)

func wrap_screen(amount):
	transform.origin += amount

func is_attacking():
	return attack_node.get_ref()

func get_animation():
	if is_attacking():
		return "attack"
	elif not is_on_floor():
		if $AnimatedSprite2D.sprite_frames.has_animation("jump_up"):
			if velocity.y < 0:
				return "jump_up"
			else:
				return "jump_down"
		else:
			return "jump"
	elif axes_pressed().x != 0:
		return "walk"
	else:
		return "idle"

func do_draw():
	pass

func _draw():
	do_draw()

func _process(delta):
	if not dead:
		time += delta
	if not is_attacking():
		attack_timeout = max(0, attack_timeout - delta)
	special_timeout = max(0, special_timeout - delta)
	
	if not dead:
		var poison_opacity = 0
		if poisoned_by != null:
			var poison_time = $PoisonTimer.time_left / $PoisonTimer.wait_time
			poison_opacity = .5 + cos(32*PI*poison_time*poison_time)
		$Poison.modulate = Color(1,1,1,poison_opacity)
		
		revive_countdown = max(0, revive_countdown - delta)
		var opacity = 1
		if revive_countdown > 0:
			opacity = .5 + cos(8*PI*revive_countdown*revive_time)/2
		modulate = Color(1,1,1,opacity)
		
		slimed = max(0, slimed - delta)
		
		$AnimatedSprite2D.animation = get_animation()
		var an = attack_node.get_ref()
		if an:
			an.get_node("AnimatedSprite2D").flip_h = $AnimatedSprite2D.flip_h
			an.transform.origin.x = abs(an.transform.origin.x)
			an.transform.origin.x *= facing()
	
	if spore:
		spore.sync_sprite($AnimatedSprite2D)

func is_vulnerable():
	return not self.dead and revive_countdown <= 0

func make_score(other):
	ate += 1
	emit_signal("made_hit")
	if other == poisoned_by:
		poisoned_by = null

func hit(other):
	if 'spore' in other and other.spore and other.spore.grown:
		other.spore.fungus.make_score(other)
		other.spore.burst()
	else:
		make_score(other)
	other.die()

func infect(other):
	if spore == null:
		spore = Spore.instantiate()
		spore.fungus = other
		spore.set_palette(other.palette)
		spore.connect("release",Callable(self,"die"))
		add_child(spore)
		move_child(spore, 0)

func poison(other):
	poisoned_by = other
	$PoisonTimer.start()

func slime():
	slimed = slime_time

func ensnare(web):
	var point = web.intersection_center(self.position)
	if point != null:
		webs.append(web)
		web_points[web.get_instance_id()] = point
	else:
		point = web.intersection_center(self.position)

func desnare(web):
	web_points.erase(web.get_instance_id())
	webs.erase(web)

func die():
	fed += 1
	if not dead:
		dead = true
		$AnimatedSprite2D.play('dead')
		$RespawnTimer.start()
	reset_brain()

func _on_RespawnTimer_timeout():
	$AnimatedSprite2D.play('decay')

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite2D.animation == "decay":
		emit_signal("respawn", self)

func revive(new_pos):
	velocity = Vector2()
	to_velocity = Vector2()
	position = new_pos
	dead = false
	poisoned_by = null
	if spore:
		remove_child(spore)
		spore.queue_free()
		spore = null
	$AnimatedSprite2D.flip_v = false
	# for invincibilty after revive
	revive_countdown = revive_time

func easeoutback(t, p=4):
	return 1-pow(2*(t-.5), p)

func _on_PoisonTimer_timeout():
	if poisoned_by:
		poisoned_by.make_score(self)
		die()
		poisoned_by = null

var brain = init_brain()
func init_brain():
	return {
		'wander': 0,
		'direction': Vector2(1, 0),
		'target': null,
		'path': null,
		'attack_accuracy': 0.5,
		'special_accuracy': 0.5,
		'state': 'attack',
		'seek_ground': true,
		'safe_spot': null,
	}

func reset_brain():
	brain.target = null
	brain.path = null
	brain.safe_spot = null

func should_attack(enemy):
	var diff = enemy.position - position
	return abs(diff.y) < size.y/2 and abs(diff.x) < attack_range

func should_special(_enemy, _path=[]):
	return false

func should_jump(_enemy, path=[]):
	if path.size() == 0:
		return false
	if jump_dist > 0:
		var corner = $BRCorner if facing() > 0 else $BLCorner
		if is_on_floor() and corner.get_overlapping_bodies().size() == 0:
			# on a ledge, check if our path is to jump
			var jumpto = null
			for point in path:
				if abs(point.y - position.y) < size.y:
					jumpto = point
				else:
					break
			if jumpto and abs(jumpto.x - position.x) > size.x:
				return true
	if jump_height > 0:
		var dy = position.y - path[0].y
		if dy > 0 and dy < 16*8:  # make sure we're not wrapping
			return true
	return false

func can_be_target(enemy, filter_ops={}):
	for k in filter_ops.keys():
		if (k in enemy) != filter_ops[k]:
			return false
	return enemy != null and not enemy.dead and not enemy.hiding

func closest_enemy(filter_ops={}):
	var closest = null
	var target = null
	for enemy in get_enemies():
		if can_be_target(enemy, filter_ops):
			var dist = pathfinder.distance_to_enemy(enemy)
			if closest == null or (dist != 0 and closest > dist):
				target = enemy
				closest = dist
	return target

func can_stand(x, y):
	return tilemap.get_cell(x, y) == Global.INVALID_CELL \
			and tilemap.get_cell(x, y+1) != Global.INVALID_CELL

func safe_spot():
	if brain.safe_spot == null:
		var target = closest_enemy({'safe': true})
		if target == null:
			return null
		# go to the first air tile under the first ground tile under the closest
		# enemy
		var spot = target.position + Vector2(0, cell_size.y)
		spot.y = wrapf(spot.y, 0, screen_size.y)
		# find first ground
		while tilemap.get_cell_source_id(0, Global.round2(spot / cell_size)) == Global.INVALID_CELL:
			spot += Vector2(0, cell_size.y)
			spot.y = wrapf(spot.y, 0, screen_size.y)
		# find first air
		while tilemap.get_cell_source_id(0, Global.round2(spot / cell_size)) != Global.INVALID_CELL:
			spot += Vector2(0, cell_size.y)
			spot.y = wrapf(spot.y, 0, screen_size.y)
		brain.safe_spot = pathfinder.ground_below_pos(spot) 
	return brain.safe_spot

func target_position():
	if not can_be_target(brain.target):
		brain.target = null
	if brain.target == null:
		brain.target = closest_enemy()
	if brain.target:
		return brain.target.position
	return null

func target_path():
	pass

func think_position():
	return position

func path_in_sync(path, target):
	if path.size() < 1:
		return false
	return (path[path.size()-1] - target.position).length() <= 16

func think(delta):
	if not is_instance_valid(brain.target) or (brain.target and brain.target.dead):
		brain.target = closest_enemy()
		brain.path = null
	
	attack(delta)
	# TODO: less aggro state?

func attack(delta):
	var target = target_position()
	if brain.target != null and target != null:
		if brain.path == null or not path_in_sync(brain.path, brain.target):
			if brain.seek_ground:
				# TODO: only go up so far
				brain.path = pathfinder.path_between(think_position(), pathfinder.ground_below_pos(target))
			else:
				brain.path = pathfinder.path_between(think_position(), target)
		if not follow_path(brain.path):
			# too close for paths
			move_toward_point(target)
		if randf() <= brain.special_accuracy * delta and should_special(brain.target, brain.path):
			input.press('special')
		if should_attack(brain.target):
			brain.attack_cooldown = 0.5
			if randf() <= brain.attack_accuracy:
				input.press('attack')
			brain.target = null

func wander_wall():
	# i said maaaaaaybe
	if self.is_on_wall():
		brain.direction.x *= -1

func wander(delta):
	brain.wander -= delta
	#TODO: turn around if you're getting close to an enemy
	if brain.wander <= 0:
		brain.wander = randf() * 10 + 5
		if randf() > 0.3:
			brain.direction *= -1
	else:
		wander_wall()
	input.press_axis(brain.direction)

func follow_path(path):
	var next = point_on_path(path)
	if next:
		move_toward_point(next)
		if should_jump(brain.target, path):
			input.press('special')
		return true
	return false

func point_on_path(path):
	var next = null
	if path.size() > 1:
		next = path[0]
		while abs(next.y - think_position().y) < 16 and abs(next.x - think_position().x) < 8:
			path.remove_at(0)
			if path.size() > 0:
				next = path[0]
			else:
				next = null
				break
		if next:
			$PathVis.clear_points()
			for point in path:
				$PathVis.add_point(point - position)
			return next

func move_toward_point(point):
	var dir = point - think_position()
	if abs(dir.x) > 16*8:
		dir.x *= -1 # wrap around map
	if abs(dir.x) > 6 or (dir.y > 2 and is_on_floor()):
		# don't spin in place
		input.press_axis(Vector2(dir.x, 0))

