extends Area2D

var fungus = null
var grown = false
var releasing = false
signal release

const texture = preload("res://art/fungus.png")

func _ready():
	$Fungus.play("grow")
	var frames = $Fungus.sprite_frames.get_frame_count("grow")
	var seconds = $GrowTimer.wait_time
	$Fungus.sprite_frames.set_animation_speed("grow", frames/seconds)

func set_palette(palette):
	$Fungus.material.set_shader_parameter("palette", palette)
	
	# set particle color from palette
	var image = texture.get_image()
	false # image.lock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	$Fungus/CPUParticles2D.color = image.get_pixel(palette, 0)
	false # image.unlock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

func infect_rate():
	var full_infect = $GrowTimer.wait_time
	return max(full_infect - $GrowTimer.time_left, 0)/full_infect

func sync_sprite(from_sprite):
	$Fungus.flip_h = from_sprite.flip_h
	$Fungus.flip_v = from_sprite.flip_v
	$Fungus.rotation = from_sprite.rotation

func _on_GrowTimer_timeout():
	grown = true
	$LifeTimer.start()

func _on_LifeTimer_timeout():
	release.emit()
	burst()

func burst():
	$Fungus.play("release")
	$Fungus/CPUParticles2D.restart()
	releasing = true
	var cell = Global.floor2(global_position / Vector2(16,16)) # TODO cell size?
	for dir in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
		var side = cell + dir
		if fungus.ground_cell(side):
			fungus.add_myc(side, -dir)

func _process(delta):
	if releasing:
		for player in get_overlapping_bodies():
			if player.has_method('infect') and not player.dead:
				player.infect(fungus)
