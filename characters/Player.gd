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

var attack_wait = 1
var attack_timeout = 0

var screen_size
signal made_hit
signal respawn(player)

var velocity = Vector2()
var jumping = false
var size = Vector2(16, 16) # todo: dynamic
var attackNode = weakref(null)
var dead = false

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
	return "Shroo"


func special():
	if is_on_floor():
		jumping = true
		velocity.y = jump_speed

func attack():
	if attack_timeout <= 0:
		attack_timeout = attack_wait
		make_attack()

func make_attack(offset=Vector2(0,0)):
	var instance = attack_scene.instance()
	instance.attacker = self
	instance.transform.origin += offset
	instance.set_name("attack")
	instance.configure(attack_anim)
	add_child(instance)
	attackNode = weakref(instance)
	$AnimatedSprite.play("attack")
	return instance

func walk():
	velocity.x = 0
	var x = Input.get_axis(inputs['left'], inputs['right'])
	velocity.x += x * run_speed
	if x != 0:
		$AnimatedSprite.flip_h = x > 0

func get_input(delta):
	if not dead:
		walk()
			
		if Input.is_action_just_pressed(inputs['special']):
			special()
			
		if Input.is_action_just_pressed(inputs['attack']):
			attack()


func _physics_process(delta):
	if jumping and is_on_floor():
		jumping = false
	get_input(delta)
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
	elif velocity.length() > 0:
		return "walk"
	else:
		return "idle"

func _process(delta):
	if not is_attacking():
		attack_timeout = max(0, attack_timeout - delta)
	
	if not dead:
		$AnimatedSprite.animation = get_animation()
		var an = attackNode.get_ref()
		if an:
			an.get_node("AnimatedSprite").flip_h = $AnimatedSprite.flip_h
			an.transform.origin.x = abs(an.transform.origin.x)
			if not $AnimatedSprite.flip_h:
				an.transform.origin.x *= -1


func hit():
	ate += 1
	emit_signal("made_hit")


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
	# TODO: invincibilty after revive


func easeoutback(t, p=4):
	return 1-pow(2*(t-.5), p)
