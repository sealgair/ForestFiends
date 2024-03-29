extends "res://screens/Screen.gd"

var players = []
var player_data = []
var EnterScore = preload("res://screens/victory/EnterScore.tscn")
var enter_node = weakref(null)
var enter_score

func score_sorter(a, b):
	return a.score > b.score

func _ready():
	super()
	players.sort_custom(Callable(self,'score_sorter'))
	var prev = null
	var place = 1
	var awards
	var player_displays
	if players.size() > 0:
		awards = make_awards(players)
		player_displays = [
			$Player1,
			$Player2,
			$Player3,
			$Player4,
		]
	for p in range(players.size()):
		var player = players[p]
		if prev and prev.score != player.score:
			place += 1
		var display = player_displays[p]
		display.set_player(player, place)
		display.set_quip(awards[p])
		prev = player
		# for restart
		player_data.append({
			'order': player.order,
			'species': player.get_species(),
			'palette': player.palette,
			'computer': player.computer
		})
		Global.add_player_stats(player)
		if Global.check_highscore(0 if player.computer else player.score):
			var enter = EnterScore.instantiate()
			add_child(enter)
			enter.set_player(player.order, player.get_species(), player.score)
			enter_node = weakref(enter)
	
	for input in inputs:
		input.set_mappings({
			'replay': 'a',
			'change': 'b'
		})

func most(arr):
	var highest = null
	var id = null
	for i in range(arr.size()):
		var val = arr[i]
		if highest == null or val > highest:
			highest = val
			id = i
	return id

func least(arr):
	var lowest = null
	var id = null
	for i in range(arr.size()):
		var val = arr[i]
		if lowest == null or val < lowest:
			lowest = val
			id = i
	return id

func make_awards(award_players):
	var empty = [0,0,0,0]
	var hit_rates = empty.duplicate()
	var distances = empty.duplicate()
	var specials = empty.duplicate()
	var attacks = empty.duplicate()
	var deaths = empty.duplicate()
	# no deaths
	# no kills
	var awards = {}
	for p in range(award_players.size()):
		var player = award_players[p]
		awards[p] = []
		if player.attacks > 0:
			hit_rates[p] = player.ate / player.attacks
		else:
			hit_rates[p] = 0
		distances[p] = player.distance
		specials[p] = player.specials
		attacks[p] = player.attacks
		deaths[p] = player.fed
	# TODO: sort by standard deviations from mean, use most significant ones
	awards[most(hit_rates)].append("Looks like you don't miss.")
	awards[least(hit_rates)].append("Try biting *toward* them next time.")
	awards[most(distances)].append("A squirrely one, aintcha?")
	awards[least(distances)].append("Letting them come to you, huh?")
	awards[most(specials)].append("I guess you think you're pretty special.")
	awards[least(specials)].append("Keeping it simple? That's ok, I get confused too.")
	awards[most(attacks)].append("If you attack enough, you're bound to hit something.")
	awards[least(attacks)].append("You must be a lover, not a fighter.")
	awards[most(deaths)].append("Oof. Well, you spent *some* time alive...")
	awards[least(deaths)].append("That's right, don't let them touch you.")
	for p in range(awards.size()):
		if awards[p].size() == 0:
			awards[p] = "Not the most interesting performance, but that's ok."
		else:
			awards[p].shuffle()
			awards[p] = awards[p][0]
	return awards


func _process(delta):
	super(delta)
	$ContinueTimer.paused = enter_node.get_ref() != null
	if enter_node.get_ref() == null:
		for input in inputs:
			if input.is_just_pressed('replay'):
				SceneSwitcher.change_to_scene(
					'play',
					{'start_data': player_data}, 
					"circle",
					Vector2(0,1)
				)
			if input.is_just_pressed('change'):
				SceneSwitcher.change_to_scene(
					'select', {}, ["diagonal"]
				)

