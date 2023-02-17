extends Node2D

var growth = 0

func _process(delta):
	var frames = $AnimatedSprite.frames.get_frame_count("grow")
	$AnimatedSprite.frame = min(floor(growth * frames), frames-1)

func init(dir, start_growth=0, palette=0):
	growth = start_growth
	$AnimatedSprite.rotation = dir.angle() + TAU/4
	$AnimatedSprite.flip_h = randf() > 0.5
	$AnimatedSprite.material.set_shader_param("palette", palette)

func grow(amount):
	growth = min(growth+amount, 1)

func can_spread():
	return growth >= 0.5
