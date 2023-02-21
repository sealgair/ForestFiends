extends Area2D

export (float) var live = 0.5
var life = 0

var attacker

func _ready():
	life = live

func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()

func configure(anim="idle", size=6):
	var frames = $AnimatedSprite.frames.get_frame_count(anim)
	$AnimatedSprite.frames.set_animation_speed(anim, frames/live)
	$AnimatedSprite.play(anim)


func extend():
	life = max(life, live/2)

func _on_Attack_body_entered(body):
	if body != attacker and body.is_vulnerable():
		$CollisionShape2D.set_deferred("disabled", true)
		attacker.hit(body)
