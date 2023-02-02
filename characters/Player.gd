extends KinematicBody2D

const PlayerInput = preload("res://main/PlayerInput.gd")
const ComputerInput = preload("res://main/ComputerInput.gd")
const attack_scene = preload("res://characters/Attack.tscn")
var PlayerPath = preload("res://brain/PlayerPath.gd")

export (int) var order = 1
export (int) var palette = null
export (bool) var computer = false

var ate = 0
var fed = 0
var score = 0
var time = 0
var distance = 0
var attacks = 0
var specials = 0

var input
var run_speed = 100
var jump_speed = -450
var gravity = 1200
var accelerate = 10
var decelerate = 20

var jump_height = 0
var jump_dist = 0
var attack_range = 8

var attack_wait = 1
var attack_timeout = 0
var attack_offset = Vector2(16,0)
var revive_countdown = 0
var revive_time = 2

var special_wait = 1
var special_timeout = 0

var screen_size
signal made_hit
signal respawn(player)

var velocity = Vector2()
var to_velocity = Vector2()
var jumping = false
var size = Vector2(16, 16) # todo: dynamic
var attack_node = weakref(null)
var dead = false
var poisoned_by = null
var slimed = 0
var slime_time = 2
var webs = []
var web_points = {}

var attack_anim = "default"
var enemies = []

var tilemap
var pathfinder

func _ready():
	screen_size = get_viewport_rect().size
	set_computer(computer)
	if palette == null:
		palette = order - 1
	$AnimatedSprite.material.set_shader_param("palette", palette)

func make_enemies(all_players):
	for player in all_players:
		if player != self:
			enemies.append(player)

func init(start_pos, the_tilemap):
	position = start_pos
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

func make_slime(position, palette=0):
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
	var instance = attack_scene.instance()
	instance.attacker = self
	instance.transform.origin += attack_offset
	instance.set_name("attack")
	instance.configure(attack_anim)
	add_child(instance)
	attack_node = weakref(instance)
	$AnimatedSprite.play("attack")
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
	if $AnimatedSprite.flip_h:
		result.x = 1
	if $AnimatedSprite.flip_v:
		result.y = -1
	return result

func axes_pressed():
	if is_mobile():
		return input.direction_pressed()
	else:
		return Vector2(0,0)

# warning-ignore:unused_argument
func move(x, y):
	to_velocity = velocity * 1 # copy
	to_velocity.x = x * run_speed
	
	if x != 0:
		$AnimatedSprite.flip_h = x > 0

# warning-ignore:unused_argument
func moved(delta):
	pass

func handle_input(delta):
	if computer and input.override():
		set_input(PlayerInput.new(order))
		computer = false
	
	var axes = axes_pressed()
	move(axes.x, axes.y)
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
				attack_pressed()
		if input.is_just_released('attack'):
			attack_released()

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
		velocity.y += gravity * delta
	var before = position
	velocity = move_and_slide(velocity, Vector2(0, -1))
	distance += (position - before).length()
	
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
		return "jump"
	elif axes_pressed().x != 0:
		return "walk"
	else:
		return "idle"

func _process(delta):
	if not is_attacking():
		attack_timeout = max(0, attack_timeout - delta)
	special_timeout = max(0, special_timeout - delta)
	
	if not dead:
		time += delta
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
		
		$AnimatedSprite.animation = get_animation()
		var an = attack_node.get_ref()
		if an:
			an.get_node("AnimatedSprite").flip_h = $AnimatedSprite.flip_h
			an.transform.origin.x = abs(an.transform.origin.x)
			an.transform.origin.x *= facing()

func is_vulnerable():
	return not self.dead and revive_countdown <= 0

func make_score(other):
	ate += 1
	emit_signal("made_hit")
	if other == poisoned_by:
		poisoned_by = null

func hit(other):
	make_score(other)
	other.die()

func poison(other):
	poisoned_by = other
	$PoisonTimer.start()

func slime():
	slimed = slime_time

func ensnare(web):
	var point = web.intersection_center(self)
	if point != null:
		webs.append(web)
		web_points[web.get_instance_id()] = point
	else:
		point = web.intersection_center(self)

func desnare(web):
	web_points.erase(web.get_instance_id())
	webs.erase(web)

func die():
	fed += 1
	if not dead:
		dead = true
		$AnimatedSprite.play('dead')
		$RespawnTimer.start()

func _on_RespawnTimer_timeout():
	$AnimatedSprite.play('decay')

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "decay":
		emit_signal("respawn", self)

func revive(new_pos):
	velocity = Vector2()
	to_velocity = Vector2()
	position = new_pos
	dead = false
	poisoned_by = null
	$AnimatedSprite.flip_v = false
	# for invincibilty after revive
	revive_countdown = revive_time

func easeoutback(t, p=4):
	return 1-pow(2*(t-.5), p)

func _on_PoisonTimer_timeout():
	if poisoned_by:
		poisoned_by.make_score(self)
		die()
		poisoned_by = null

func abs2(vec2):
	return Vector2(abs(vec2.x), abs(vec2.y))

var brain = {
	'wander': 0,
	'direction': 1,
	'target': null,
	'attack_accuracy': 0.2,
	'special_accuracy': 0.2,
}

func should_attack(enemy):
	return abs(position.x - enemy.position.x) < attack_range

func should_special(enemy, path=[]):
	return false

func should_jump(enemy, path=[]):
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

func think(delta):
	$PathVis.clear_points()
	
	var closest = null
	if brain.target and brain.target.dead:
		brain.target = null
	if not brain.target:
		for enemy in enemies:
			if not enemy.dead:
				var dist = pathfinder.distance_to_enemy(enemy)
				if closest == null or (dist != 0 and closest > dist):
					brain.aggro = true
					brain.target = enemy
					closest = dist
	if brain.target:
		var path = pathfinder.path_to_enemy(brain.target)
		var next = null
		if path.size() > 1:
			next = path[0]
			while abs(next.y - position.y) < 16 and abs(next.x - position.x) < 8:
				path.remove(0)
				if path.size() > 0:
					next = path[0]
				else:
					next = null
					break
			if next:
				for point in path:
					$PathVis.add_point(point - position)
				move_toward_point(next)
		if (randf() <= brain.special_accuracy and should_special(brain.target, path)) \
				or should_jump(brain.target, path):
			input.press('special')
		if should_attack(brain.target):
			brain.attack_cooldown = 0.5
			if randf() <= brain.attack_accuracy:
				input.press('attack')
	else:
		return
		if is_on_wall():
			brain.direction *= -1
		if brain.wander > 0:
			brain.wander = max(brain.wander-1, 0)
		if brain.wander < 0: 
			brain.wander = min(brain.wander+1, 0)
		if brain.wander == 0:
			# come up with a new direction
			brain.wander = 1 + randf() * 10
			brain.wander *= sign(randf() - 0.5)
		if abs(brain.wander) > 1:
			input.press_axis(Vector2(brain.direction, 0))

func move_toward_point(point):
	var dir = point.x - position.x
	if abs(dir) > 16*8:
		dir *= -1 # wrap around map
	input.press_axis(Vector2(dir, 0))
