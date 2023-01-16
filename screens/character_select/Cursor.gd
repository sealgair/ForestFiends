extends Node2D

var cell = Vector2()
var size = Vector2(3,3) # TODO: dynamic
var palette = 0
var players
var selected = false

func _ready():
	players = [
		$Player1,
		$Player2,
		$Player3,
		$Player4,
	]
	set_selected(selected)

func move(direction):
	if selected:
		var amount = sign(direction.x - direction.y)
		palette = wrapi(palette+amount, 0, 4)
	else:
		cell += direction
		cell.x = wrapi(cell.x, 0, size.x)
		cell.y = wrapi(cell.y, 0, size.y)


func set_selected(new_selected):
	selected = new_selected
	for player in players:
		player.animation = "selected" if selected else "default"
	if not selected:
		palette = 0


func set_player(player):
	for p in range(players.size()):
		players[p].visible = p == player
