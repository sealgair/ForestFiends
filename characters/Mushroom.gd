extends KinematicBody2D

var grown = false
var burst = false
var done = false
var facing = Vector2(0, -1)

signal die(mushroom)
signal fed

var texture = preload("res://art/fungus.png")

func _ready():
	$AnimatedSprite.play('grow')

func init(dir, palette=0):
	facing = dir
	$AnimatedSprite.material.set_shader_param("palette", palette)
	if dir.y != 0:
		$AnimatedSprite.flip_v = dir.y > 0
		$AnimatedSprite.flip_h = randf() > 0.5
		$SporeArea.transform.origin.x = 8
		$SporeArea.transform.origin.y = 8 + 8 * dir.y
	elif dir.x != 0:
		$AnimatedSprite.rotate(TAU / 4)
		$AnimatedSprite.offset = Vector2(0, -16)
		$AnimatedSprite.flip_v = dir.x < 0
		$AnimatedSprite.flip_h = randf() > 0.5
		$SporeArea.transform.origin.y = 8
		$SporeArea.transform.origin.x = 8 + 8 * dir.x
	$Spores.direction = dir
	
	# set particle color from palette
	var image = texture.get_data()
	image.lock()
	$Spores.color = image.get_pixel(palette, 0)
	image.unlock()

func burst():
	if grown and not burst:
		$AnimatedSprite.play('burst')
		$Spores.restart()
		burst = true
		$DecayTimer.start()
		return true
	return false

func spore_bodies():
	return $SporeArea.get_overlapping_bodies()

func wrap_cell(cell):
	return Global.wrap2(cell, Vector2(), Vector2(16,16))

func spore_tile(tilemap):
	var cell = Global.floor2(position / tilemap.cell_size)
	var d = 5 + facing.y
	for i in range(1,d):
		var check = wrap_cell(cell + facing * i)
		if tilemap.get_cellv(check) != tilemap.INVALID_CELL:
			return check
		for j in range(1, i+1):
			var s = Vector2()
			if facing.x != 0:
				s.y = j
			else:
				s.x = j
			if (facing * i + s).length() <= d:
				for check_s in [wrap_cell(check + s), wrap_cell(check - s)]:
					if tilemap.get_cellv(check_s) != tilemap.INVALID_CELL:
						return check_s
	return null

func is_vulnerable():
	return $AnimatedSprite.animation == 'grow'

func die():
	$AnimatedSprite.play('die')
	emit_signal("fed")
	$DecayTimer.start()

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == 'grow':
		grown = true

func _on_DecayTimer_timeout():
	emit_signal("die", self)
