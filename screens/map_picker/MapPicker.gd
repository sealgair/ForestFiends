extends "res://screens/Screen.gd"

var map_choices = []
var cursor = Vector2(0,0)
var input
var start_players = []

func _ready():
	map_choices = [
		[$MapChoice1, $MapChoice2, $MapChoice3],
		[$MapChoice4, $MapChoice5, $MapChoice6],
		[$MapChoice7, $MapChoice8, $MapChoice9],
	]
	
	# randomly pick a (non-computer) player to pick the level
	var humans = []
	for p in range(start_players.size()):
		if not start_players[p]['computer']:
			humans.append(p)
	var i = Global.rand_choice(humans)
	input = inputs[0]
	$PlayerChoice.text = "Player %d chooses" % i


func _process(delta):
	var dir = input.direction_just_pressed(true)
	
	for x in range(3):
		for y in range(3):
			map_choices[x][y].set_selected(false)
	
	var found = false
	while not found:	
		cursor += dir
		cursor.x = wrapi(cursor.x, 0, 3)
		cursor.y = wrapi(cursor.y, 0, 3)
		found = map_choices[cursor.x][cursor.y].visible
	map_choices[cursor.x][cursor.y].set_selected(true)
	
	if input.is_just_pressed("select"):
		start_game()


func start_game():
	var chosen = map_choices[cursor.x][cursor.y]
	ScreenManager.load_screen("play", {
		"start_data": start_players,
		"map_scene": chosen.map_scene
	})
