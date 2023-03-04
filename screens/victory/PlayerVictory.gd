extends Node2D

@export var place: int = 1
var player

var places = ["1st", "2nd", "3rd", "4th"]
var place_anims = ["gold", "silver", "bronze", "lead"]


# Called when the node enters the scene tree for the first time.
func _ready():
	if player:
		set_player(player, place)

func set_player(new_player, new_place):
	player = new_player
	place = new_place
	if player.computer:
		$Player.text = "CPU"
	else:
		$Player.text = "PL"
	$Player.text += str(player.order)
	$Place.text = places[place-1]
	$AnimatedSprite2D.play(place_anims[place-1])
	$AminalSprite.set_aminal(player)
	$Place.add_theme_color_override("font_color", Global.player_colors[player.order-1])
	$Player.add_theme_color_override("font_color", Global.player_colors[player.order-1])
	$Ate.text = "Ate: {v}".format({'v': player.ate})
	$Fed.text = "Fed: {v}".format({'v': player.fed})
	$Points.text = "Pts: {v}".format({'v': Global.comma_sep(player.score)})

func set_quip(quip):
	$Quip.text = quip
