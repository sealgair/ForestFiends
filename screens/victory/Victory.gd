extends "res://screens/Screen.gd"

var players = []
var player_data = []
var PlayerVictory = preload("res://screens/victory/PlayerVictory.tscn")
var EnterScore = preload("res://screens/victory/EnterScore.tscn")
var enter_node = weakref(null)
var enter_score

func score_sorter(a, b):
	return a.score > b.score

func _ready():
	var column = get_viewport_rect().size.x / players.size()
	var x = 0
	players.sort_custom(self, 'score_sorter')
	var prev = null
	var place = 1
	for player in players:
		if prev and prev.score != player.score:
			place += 1
		var pv = PlayerVictory.instance()
		pv.player = player
		pv.place = place
		pv.transform.origin.y = 64
		pv.transform.origin.x = x + column / 2
		x += column
		add_child(pv)
		prev = player
		# for restart
		player_data.append({
			'order': player.order,
			'species': player.get_species(),
			'palette': player.palette
		})
		Global.add_player_stats(player)
		if Global.check_highscore(0 if player.computer else player.score):
			var enter = EnterScore.instance()
			add_child(enter)
			enter.set_player(player.order, player.get_species(), player.score)
			enter_node = weakref(enter)
	
	for input in inputs:
		input.set_mappings({
			'replay': 'a',
			'change': 'b'
		})


func _process(delta):
	$ContinueTimer.paused = enter_node.get_ref() != null
	if enter_node.get_ref() == null:
		for input in inputs:
			if input.is_just_pressed('replay'):
				ScreenManager.load_screen('play', {'start_data': player_data})
			if input.is_just_pressed('change'):
				ScreenManager.load_screen('select')

