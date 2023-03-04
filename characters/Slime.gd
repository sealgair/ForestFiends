extends Area2D

func _ready():
	$Timer.start()
	$AnimatedSprite2D.flip_h = randf() > 0.5
	var time = $Timer.wait_time
	var frames = $AnimatedSprite2D.sprite_frames.get_frame_count("default")
	$AnimatedSprite2D.sprite_frames.set_animation_speed("default", frames/time)
	$AnimatedSprite2D.play("default")

func refresh():
	$Timer.start()
	$AnimatedSprite2D.frame = 0
	
func set_palette(palette):
	$AnimatedSprite2D.material.set_shader_parameter("palette", palette)

func _on_Slime_body_entered(body):
	body.slime()

func _on_Timer_timeout():
	queue_free()
