extends Area2D


func _ready():
	$Timer.start()


func refresh():
	$Timer.start()
	

func set_palette(palette):
	$AnimatedSprite.material.set_shader_param("palette", palette)

func _process(delta):
	if $Timer.time_left < $Timer.wait_time / 3:
		$AnimatedSprite.animation = "fading"


func _on_Slime_body_entered(body):
	body.slime()


func _on_Timer_timeout():
	queue_free()
