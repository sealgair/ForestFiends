extends Area2D

func _ready():
	$Timer.start()
	$AnimatedSprite.flip_h = randf() > 0.5
	var time = $Timer.wait_time
	var frames = $AnimatedSprite.frames.get_frame_count("default")
	$AnimatedSprite.frames.set_animation_speed("default", frames/time)
	$AnimatedSprite.play("default")

func refresh():
	$Timer.start()
	$AnimatedSprite.frame = 0
	
func set_palette(palette):
	$AnimatedSprite.material.set_shader_param("palette", palette)

func _on_Slime_body_entered(body):
	body.slime()

func _on_Timer_timeout():
	queue_free()
