extends Node2D

var growth = 0

func _process(delta):
	var frames = $AnimatedSprite.frames.get_frame_count("grow")
	$AnimatedSprite.frame = min(floor(growth * frames), frames-1)

func init(dir, start_growth=0, palette=0):
	growth = start_growth
	if dir.y != 0:
		$AnimatedSprite.flip_v = dir.y > 0
		$AnimatedSprite.flip_h = randf() > 0.5
	elif dir.x != 0:
		$AnimatedSprite.rotate(TAU / 4)
		$AnimatedSprite.offset = Vector2(0, -16)
		$AnimatedSprite.flip_v = dir.x < 0
		$AnimatedSprite.flip_h = randf() > 0.5
	$AnimatedSprite.material.set_shader_param("palette", palette)

func grow(amount):
	growth = clamp(growth+amount, 0, 1)

func can_spread():
	return growth >= 0.5
