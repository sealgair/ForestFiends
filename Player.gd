extends Area2D

export var speed = 100
var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var size = Vector2(16, 16) # todo: dynamic
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		$AnimatedSprite.flip_h = true
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		$AnimatedSprite.flip_h = false
	
	if velocity.length() > 0:
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("idle")
	
	position += velocity * speed * delta
	position.x = wrapf(position.x, -size.x, screen_size.x)
	position.y = wrapf(position.y, -size.y, screen_size.y)
