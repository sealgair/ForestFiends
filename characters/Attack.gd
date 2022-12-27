extends Area2D

export (float) var live = 0.3
var life = 0

var attacker

func _ready():
	life = live

func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()


func _on_Attack_body_entered(body):
	if body != attacker and !body.dead:
		$CollisionShape2D.set_deferred("disabled", true)
		attacker.hit()
		body.die()
