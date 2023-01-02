extends "Player.gd"


func _ready():
	._ready()
	gravity = 0
	run_speed = 80
	attack_offset = Vector2(16,8)
	attack_wait = 1.5
	

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
