extends KinematicBody2D

var grown = false
var burst = false
var done = false
var facing = Vector2(0, -1)
var fungus = null

# mock up player stuff
var dead = false
var hidden = false
var poisoned_by = null
var webs = []

signal die(mushroom)
signal fed

const texture = preload("res://art/fungus.png")

func _ready():
	$AnimatedSprite.play('grow')
	$LifeTimer.wait_time = randf() * 10 + 10
	$LifeTimer.start()

func init(dir, palette=0):
	facing = dir
	$AnimatedSprite.material.set_shader_param("palette", palette)
	$AnimatedSprite.rotation = dir.angle() + TAU/4
	$AnimatedSprite.flip_h = dir.y > 0 or dir.x < 0
	$SporeArea.transform.origin += dir * $SporeArea/CollisionShape2D.shape.radius/2
	$Spores.direction = dir
	
	# set particle color from palette
	var image = texture.get_data()
	image.lock()
	$Spores.color = image.get_pixel(palette, 0)
	image.unlock()

func burst():
	if grown and not burst and not dead:
		dead = true
		$AnimatedSprite.play('burst')
		$Spores.restart()
		burst = true
		$DecayTimer.start()
		$InfectTimer.start()
		return true
	return false

func spore_bodies():
	return $SporeArea.get_overlapping_bodies()

func wrap_cell(cell):
	return Global.wrap2(cell, Vector2(), Vector2(16,16))

func spore_tile(tilemap):
	var cell = Global.floor2(position / tilemap.cell_size)
	var d = 5 + facing.y
	for i in range(d):
		var check = wrap_cell(cell + facing * i)
		if tilemap.get_cellv(check) != tilemap.INVALID_CELL:
			return check
		for j in range(1, i+2):
			var s = Global.perpendicular(facing) * j
			if (facing * i + s).length() <= d:
				for check_s in [wrap_cell(check + s), wrap_cell(check - s)]:
					if tilemap.get_cellv(check_s) != tilemap.INVALID_CELL:
						return check_s
	return null

func is_vulnerable():
	return $AnimatedSprite.animation == 'grow'

func _process(delta):
	if burst and $InfectTimer.time_left > 0:
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
	$AnimatedSprite.play('die')
	emit_signal("fed")
	$DecayTimer.start()

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == 'grow':
		grown = true

func _on_DecayTimer_timeout():
	emit_signal("die", self)


func _on_LifeTimer_timeout():
	burst()
