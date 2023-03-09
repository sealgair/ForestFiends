extends CharacterBody2D

var grown = false
var has_burst = false
var done = false
var facing = Vector2(0, -1)
var fungus = null

# mock up player stuff
var dead = false
var hiding = false
var poisoned_by = null
var webs = []

signal remove_mushroom(mushroom)
signal fed

const texture = preload("res://art/fungus.png")

func _ready():
	$AnimatedSprite2D.play('grow')
	$LifeTimer.wait_time = randf() * 10 + 10
	$LifeTimer.start()

func init(dir, palette=0):
	facing = dir
	$AnimatedSprite2D.material.set_shader_parameter("palette", palette)
	$AnimatedSprite2D.rotation = dir.angle() + TAU/4
	$AnimatedSprite2D.flip_h = dir.y > 0 or dir.x < 0
	$SporeArea.transform.origin += dir * $SporeArea/CollisionShape2D.shape.radius/2
	$Spores.direction = dir
	
	# set particle color from palette
	var image = texture.get_image()
	false # image.lock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	$Spores.color = image.get_pixel(palette, 0)
	false # image.unlock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

func burst():
	if grown and not has_burst and not dead:
		dead = true
		$AnimatedSprite2D.play('burst')
		$Spores.restart()
		has_burst = true
		$DecayTimer.start()
		$InfectTimer.start()
		return true
	return false

func spore_bodies():
	return $SporeArea.get_overlapping_bodies()

func wrap_cell(cell):
	return Global.wrap2(cell, Vector2(), Vector2(16,16))

func spore_tile(tilemap):
	var cell_size = Vector2(tilemap.tile_set.tile_size)
	var cell = Global.floor2(position / cell_size)
	var d = 5 + facing.y
	for i in range(d):
		var check = wrap_cell(cell + facing * i)
		if tilemap.get_cell_source_id(0, check) != Global.INVALID_CELL:
			return check
		for j in range(1, i+2):
			var s = Global.perpendicular(facing) * j
			if (facing * i + s).length() <= d:
				for check_s in [wrap_cell(check + s), wrap_cell(check - s)]:
					if tilemap.get_cell_source_id(0, check_s) != Global.INVALID_CELL:
						return check_s
	return null

func is_vulnerable():
	return $AnimatedSprite2D.animation == 'grow'

func _process(delta):
	if has_burst and $InfectTimer.time_left > 0:
		for player in spore_bodies():
			if player.has_method('infect'):
				player.infect(fungus)

func poison(other):
	die()
	
func slime():
	pass
	
func infect(other):
	if other != fungus and not dead:
		other.hit(self)

func die():
	dead = true
	$AnimatedSprite2D.play('die')
	emit_signal("fed")
	$DecayTimer.start()

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite2D.animation == 'grow':
		grown = true

func _on_DecayTimer_timeout():
	remove_mushroom.emit(self)

func _on_LifeTimer_timeout():
	burst()
