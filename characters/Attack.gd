extends Area2D

@export var live: float = 0.5
@export var hurt: float = 0.2
var start = 0
var life = 0

var attacker

func _ready():
	life = 0

func _process(delta):
	life += delta
	$CollisionShape2D.position.x = abs($CollisionShape2D.position.x)
	if $AnimatedSprite2D.flip_h:
		$CollisionShape2D.position.x *= -1
	if life > live:
		queue_free()

func configure(anim="idle", size=6):
	var frames = $AnimatedSprite2D.sprite_frames.get_frame_count(anim)
	$AnimatedSprite2D.sprite_frames.set_animation_speed(anim, frames/live)
	$AnimatedSprite2D.play(anim)

func extend():
	life = min(life, live/2)

func _on_Attack_body_entered(body):
	if life > start and life < start + hurt:
		if body != attacker and body.is_vulnerable():
			$CollisionShape2D.set_deferred("disabled", true)
			attacker.hit(body)
