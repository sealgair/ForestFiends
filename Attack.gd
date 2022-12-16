extends Area2D

export (float) var live = 0.3
var life = 0


func _ready():
	life = live

func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()
