extends "res://screens/Screen.gd"

var map_choices = []
var cursor = Vector2(1,1)
var input
var start_players = []
var chosing_player = null

func _ready():
	map_choices = [
		[$MapChoice1, $MapChoice2, $MapChoice3],
		[$MapChoice4, $MapChoice5, $MapChoice6],
		[$MapChoice7, $MapChoice8, $MapChoice9],
	]
	
	if chosing_player == null:
		# randomly pick a (non-computer) player to pick the level
		var humans = [0]
		for p in range(start_players.size()):
			if not start_players[p].computer:
				humans.append(p)
		chosing_player = Global.rand_choice(humans)
	input = inputs[chosing_player]
	$PlayerChoice.text = "Player %d chooses" % (chosing_player+1)


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
	if dir.length() > 0:
		# timer starts after last input
		$ContinueTimer.start()
	
	if input.is_just_pressed("select"):
		start_game()
	
	$Countdown.text = ""
	if $ContinueTimer.time_left <= 5 and not $ContinueTimer.paused:
		$Countdown.text = String(ceil($ContinueTimer.time_left))

func start_game():
	var chosen = map_choices[cursor.x][cursor.y]
	SceneSwitcher.change_scene("play", {
		"start_data": start_players,
		"map_scene": chosen.map_scene
	}, transition, transition_direction)

func _on_ContinueTimer_timeout():
	start_game()
