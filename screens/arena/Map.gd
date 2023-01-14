extends Node2D

var start_data = []
var players = []
export (int) var score_limit = 10
var score = 0

var slime_scene = preload("res://characters/Slime.tscn")
var web_scene = preload("res://characters/Web.tscn")

func _ready():
	randomize()
	$Score.text = String(score_limit)
	var spawn_points = $RespawnTiles.get_used_cells()
	for player_data in start_data:
		var player = Global.species[player_data['species']].instance()
		player.order = player_data['order']
		player.palette = player_data['palette']
		var s = randi() % spawn_points.size()
		player.init(spawn_points[s] * player.size)
		spawn_points.erase(s)
		add_child(player)
		player.connect("respawn", self, "spawn")
		player.connect("made_hit", self, "hit")
		player.connect("make_slime", self, "make_slime")
		player.connect("make_web", self, "make_web")
		players.append(player)

func hit():
	score = 0
	for player in players:
		score += player.ate
	
	if score >= score_limit:
		$VictoryTimer.start()
	else:
		$Score.text = String(score_limit - score)

func average(values):
	var sum = 0
	for value in values:
		sum += value
	return sum / values.size()


func spawnpoint_distance(spawnpoint):
	var distances = []
	for player in players:
		distances.append((player.position - spawnpoint * player.size).length())
	return average(distances)


func spawnpoint_sorter(a, b):
	return spawnpoint_distance(a) > spawnpoint_distance(b)


func spawn(player, spawn_point=null):
	if spawn_point == null:
		var spawn_points = $RespawnTiles.get_used_cells()
		# find spawn point furthest from other players
		spawn_point = spawn_points[0]
		for sp in spawn_points:
			$WebChecker.transform.origin = spawn_point * $WebChecker.transform.size
			if spawnpoint_distance(spawn_point) < spawnpoint_distance(sp):
				spawn_point = sp
	player.revive(spawn_point * player.size)


func make_slime(position, palette=0):
	var tile_pos = position / $TileMap.cell_size
	var tile_id = $TileMap.get_cellv(tile_pos)
	if tile_id != $TileMap.INVALID_CELL:
		var instance = slime_scene.instance()
		instance.transform.origin = position
		instance.set_palette(palette)
		add_child(instance)


func make_web(start, end, player):
	var web = web_scene.instance()
	web.spinner = player
	add_child(web)
	web.set_start(start)
	web.set_end(end)
	web.start_decay()


func make_score(player):
	# TODO:
	#local kpm = player.kills / (self.gametime/60)
	#local ktd = player.kills - player.deaths
	#local kpc = player.kills / self.totalkills
	#return max(0, ceil(kpm * 800 + ktd * 500 + kpc * 2000))
	return max(0, player.ate * 5 - player.fed * 2)


func end():
	for player in players:
		player.score = make_score(player)
	ScreenManager.load_screen("victory", {'players': players})


func _on_VictoryTimer_timeout():
	end()
