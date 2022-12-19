extends KinematicBody2D

export (int) var player = 1
export (int) var palette = null

var inputs = {}
var run_speed = 100
var jump_speed = -450
var gravity = 1200

var screen_size
signal hit
signal respawn(player)

var velocity = Vector2()
var jumping = false
var size = Vector2(16, 16) # todo: dynamic
var attackNode = weakref(null)
var dead = false

func _ready():
	screen_size = get_viewport_rect().size
	# button mappings
	inputs['right'] = "move_right{p}".format({'p': player}) 
	inputs['left'] = "move_left{p}".format({'p': player}) 
	inputs['special'] = "move_special{p}".format({'p': player}) 
	inputs['attack'] = "move_attack{p}".format({'p': player})
	if palette == null:
		palette = player - 1
	$AnimatedSprite.material.set_shader_param("palette", palette)
	
	# TODO: invincibilty after spawn

func special():
	if is_on_floor():
		jumping = true
		velocity.y = jump_speed

func attack():
	make_attack()

func make_attack(offset=Vector2(0,0)):
	var instance = load("res://Attack.tscn").instance()
	instance.attacker = self
	instance.transform.origin += offset
	instance.set_name("attack")
	add_child(instance)
	attackNode = weakref(instance)
	$AnimatedSprite.play("attack")

func get_input():
	velocity.x = 0
	if not dead:
		if Input.is_action_pressed(inputs['right']):
			velocity.x += run_speed
			$AnimatedSprite.flip_h = true
		if Input.is_action_pressed(inputs['left']):
			velocity.x -= run_speed
			$AnimatedSprite.flip_h = false
			
		if Input.is_action_just_pressed(inputs['special']):
			special()
			
		if Input.is_action_just_pressed(inputs['attack']):
			attack()


func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
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
	if velocity.x >= 1:
		$AnimatedSprite.flip_h = true
	if velocity.x <= -1:
		$AnimatedSprite.flip_h = false
	
	if not dead:
		$AnimatedSprite.animation = get_animation()
		var an = attackNode.get_ref()
		if an:
			an.get_node("AnimatedSprite").flip_h = $AnimatedSprite.flip_h
			an.transform.origin.x = abs(an.transform.origin.x)
			if not $AnimatedSprite.flip_h:
				an.transform.origin.x *= -1


func die():
	if not dead:
		dead = true
		$AnimatedSprite.play('dead')
		$RespawnTimer.start()
	
	
func _on_RespawnTimer_timeout():
	emit_signal("respawn", self.player)
	$DecayTimer.start()


func _on_DecayTimer_timeout():
	$AnimatedSprite.play('decay')


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "decay":
		queue_free()
