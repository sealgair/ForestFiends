extends "Player.gd"


func init(start_pos, the_tilemap):
	gravity = 0
	run_speed = 80
	attack_offset = Vector2(16,8)
	attack_wait = 1.5
	PlayerPath = load("res://brain/WaspPath.gd")
	.init(start_pos, the_tilemap)

func get_species():
	return "Wasp"

func hit(other):
	if other.poisoned_by == self:
		.hit(other)
	else:
		other.poison(self)

func move(x, y):
	.move(x, y)
	to_velocity.y = y * run_speed

func can_be_target(enemy, filter_ops={}):
	return .can_be_target(enemy) and enemy.poisoned_by != self

func move_toward_point(point):
	var dir = point - position
	 # wrap around map
	if abs(dir.x) > 16*8:
		dir.x *= -1
	if abs(dir.y) > 16*8:
		dir.y *= -1
	input.press_axis(dir)
