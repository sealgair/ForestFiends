extends "Player.gd"

var flap_speed = -150
var flaps = 0
var max_flaps = 3
var flapped = 0.0


func _ready():
	._ready()
	gravity *= .25


func special():
	if flaps <= max_flaps and flapped <= 0:
		flaps += 1
		flapped = 0.3
		velocity.y = flap_speed


func _process(delta):
	if is_on_floor():
		flaps = 0
	._process(delta)
	flapped = max(flapped-delta, 0)
