extends KinematicBody2D


export (int) var order = 1
export (int) var palette = null

var ate = 0
var fed = 0
var points = 0

var inputs = {}
var run_speed = 100
var jump_speed = -450
var gravity = 1200
var accelerate = 10
var decelerate = 20

var attack_wait = 1
var attack_timeout = 0
var attack_offset = Vector2(16,0)
var revive_countdown = 0
var revive_time = 2

var screen_size
signal made_hit
signal respawn(player)

var velocity = Vector2()
var to_velocity = Vector2()
var jumping = false
var size = Vector2(16, 16) # todo: dynamic
var attackNode = weakref(null)
var dead = false
var poisoned_by = null
var slimed = 0
var slime_time = 2
var webs = []
var web_points = {}

var attack_scene = preload("res://characters/Attack.tscn")
var attack_anim = "default"

func _ready():
	screen_size = get_viewport_rect().size
	# button mappings
	inputs['right'] = "ui_right{p}".format({'p': order})
	inputs['left'] = "ui_left{p}".format({'p': order})
	inputs['up'] = "ui_up{p}".format({'p': order})
	inputs['down'] = "ui_down{p}".format({'p': order})
	inputs['special'] = "ui_a{p}".format({'p': order}) 
	inputs['attack'] = "ui_b{p}".format({'p': order})
	if palette == null:
		palette = order - 1
	$AnimatedSprite.material.set_shader_param("palette", palette)
	

func init(start_pos):
	position = start_pos
	ate = 0
	fed = 0


func get_species():
	return "Player"


func special_pressed():
	if is_on_floor():
		jumping = true
		velocity.y = jump_speed

func special_released():
	pass

func is_special_pressed():
	return Input.is_action_pressed(inputs['special'])


func attack_pressed():
	if attack_timeout <= 0:
		attack_timeout = attack_wait
		make_attack()

func make_attack():
	var instance = attack_scene.instance()
	instance.attacker = self
	instance.transform.origin += attack_offset
	instance.set_name("attack")
	instance.configure(attack_anim)
	add_child(instance)
	attackNode = weakref(instance)
	$AnimatedSprite.play("attack")
	return instance


func attack_released():
	pass


func is_attack_pressed():
	return Input.is_action_pressed(inputs['attack'])


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
		return Vector2(
			Input.get_axis(inputs['left'], inputs['right']),
			Input.get_axis(inputs['up'], inputs['down'])
		)
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
	if not dead:
		var axes = axes_pressed()
		move(axes.x, axes.y)
		moved(delta)
			
		if Input.is_action_just_pressed(inputs['special']):
			special_pressed()
		if Input.is_action_just_released(inputs['special']):
			special_released()
			
		if Input.is_action_just_pressed(inputs['attack']):
			attack_pressed()
		if Input.is_action_just_released(inputs['attack']):
			attack_released()


func _physics_process(delta):
	if jumping and is_on_floor():
		jumping = false
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
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	# use transform not position so as not to break physics
	transform.origin.x = wrapf(transform.origin.x, 0, screen_size.x)
	transform.origin.y = wrapf(transform.origin.y, 0, screen_size.y)


func is_attacking():
	return attackNode.get_ref()

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
		
		$AnimatedSprite.animation = get_animation()
		var an = attackNode.get_ref()
		if an:
			an.get_node("AnimatedSprite").flip_h = $AnimatedSprite.flip_h
			an.transform.origin.x = abs(an.transform.origin.x)
			an.transform.origin.x *= facing()


func is_vulnerable():
	return not self.dead


func score(other):
	ate += 1
	emit_signal("made_hit")
	if other == poisoned_by:
		poisoned_by = null
	

func hit(other):
	score(other)
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
	position = new_pos
	dead = false
	poisoned_by = null
	# for invincibilty after revive
	revive_countdown = revive_time


func easeoutback(t, p=4):
	return 1-pow(2*(t-.5), p)


func _on_PoisonTimer_timeout():
	if poisoned_by:
		poisoned_by.score(self)
		die()
		poisoned_by = null
