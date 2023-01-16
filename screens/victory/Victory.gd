extends Node2D

var players = []
var player_data = []
var PlayerVictory = preload("res://screens/victory/PlayerVictory.tscn")
var inputs = {}

func score_sorter(a, b):
	return a.score < b.score

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

	for p in range(4):
		var pl = p+1
		inputs[p] = {
			'replay': 'ui_a{p}'.format({"p": pl}),
			'change': 'ui_b{p}'.format({"p": pl}),
		}

func _process(delta):
	for i in range(4):
		var inp = inputs[i]
		if Input.is_action_just_pressed(inp['replay']):
			ScreenManager.load_screen('play', {'start_data': player_data})
		if Input.is_action_just_pressed(inp['change']):
			ScreenManager.load_screen('select')
