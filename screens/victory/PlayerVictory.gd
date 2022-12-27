extends Node2D

export (int) var place = 1
var player

var places = ["1st", "2nd", "3rd", "4th"]
var place_anims = ["gold", "silver", "bronze", "lead"]


# Called when the node enters the scene tree for the first time.
func _ready():
	if player:
		$Place.text = places[place-1]
		$AnimatedSprite.play(place_anims[place-1])
		$AminalSprite.set_aminal(player)
		$Place.add_color_override("font_color", Global.player_colors[player.order-1])
		$Ate.text = "Ate: {v}".format({'v': player.ate})
		$Fed.text = "Fed: {v}".format({'v': player.fed})
		$Points.text = "Pts: {v}".format({'v': player.points})


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
