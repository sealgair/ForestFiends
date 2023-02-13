extends Node2D

var grown = false

func _ready():
	$AnimatedSprite.play('grow')

func init(dir):
	if dir.y != 0:
		$AnimatedSprite.flip_v = dir.y > 0
		$AnimatedSprite.flip_h = randf() > 0.5
	elif dir.x != 0:
		$AnimatedSprite.rotate(TAU / 4)
		$AnimatedSprite.offset = Vector2(0, -16)
		$AnimatedSprite.flip_v = dir.x < 0
		$AnimatedSprite.flip_h = randf() > 0.5

func _on_AnimatedSprite_animation_finished():
	grown = true
