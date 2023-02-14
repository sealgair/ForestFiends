extends KinematicBody2D

var grown = false
var burst = false
var done = false

signal die(mushroom)
signal fed

func _ready():
	$AnimatedSprite.play('grow')

func init(dir, palette=0):
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
	# TODO: set particle color

func burst():
	if grown and not burst:
		$AnimatedSprite.play('burst')
		$Spores.restart()
		burst = true
		$DecayTimer.start()
		return $SporeArea.get_overlapping_bodies()
	return []

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
