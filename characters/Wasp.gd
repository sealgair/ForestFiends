extends "Player.gd"


func _ready():
	._ready()
	gravity = 0
	run_speed = 80
	attack_offset = Vector2(16,8)
	

func get_species():
	return "Wasp"


func hit(other):
	if other.poisoned_by == self:
		.hit(other)
	else:
		other.poison(self)
	

func walk():
	.walk()
	
	velocity.y = 0
	var y = Input.get_axis(inputs['up'], inputs['down'])
	velocity.y += y * run_speed
