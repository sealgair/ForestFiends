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
		var sp = spawn_points[randi() % spawn_points.size()]
		spawn_points.erase(sp)
		player_data['spawn_point'] = sp
		add_player(player_data)


func add_player(player_data):
	var player = Global.species[player_data['species']].instance()
	player.order = player_data['order']
	player.palette = player_data['palette']
	player.init(player_data['spawn_point'] * player.size)
	add_child(player)
	player.connect("respawn", self, "spawn")
	player.connect("made_hit", self, "hit")
	player.connect("make_slime", self, "make_slime")
	player.connect("make_web", self, "make_web")
	players.append(player)
	return player


func clean():
	for web in get_tree().get_nodes_in_group("webs"):
		web.queue_free()
	for slime in get_tree().get_nodes_in_group("slime"):
		slime.queue_free()

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
		distances.append((player.position - spawnpoint).length())
	return average(distances)


func spawnpoint_sorter(a, b):
	return spawnpoint_distance(a) > spawnpoint_distance(b)


func spawn(player, spawn_point=null):
	var webs = get_webs()
	if spawn_point == null:
		var furthest = null
		# find spawn point furthest from other players
		for sp in $RespawnTiles.get_used_cells():
			sp *= $TileMap.cell_size
			var webbed = false
			for web in webs:
				if web.intersection_center(Rect2(sp, $RespawnTiles.cell_size)):
					webbed = true
					break
			if not webbed:
				var dist = spawnpoint_distance(sp)
				if furthest == null or furthest < dist:
					furthest = dist
					spawn_point = sp
	player.revive(spawn_point)


func make_slime(position, palette=0):
	var tile_pos = position / $TileMap.cell_size
	var tile_id = $TileMap.get_cellv(tile_pos)
	if tile_id != $TileMap.INVALID_CELL:
		var instance = slime_scene.instance()
		instance.transform.origin = position
		instance.set_palette(palette)
		add_child(instance)


func get_webs():
	var webs = []
	for child in get_children():
		if child.get_groups().has("webs"):
			webs.append(child)
	return webs


func make_web(start, end, player, decay=null):
	var web = web_scene.instance()
	web.spinner = player
	add_child(web)
	web.set_start(start)
	web.set_end(end)
	web.start_decay(decay)


func make_score(player):
	var kpm = player.ate / player.time / 60
	var ktd = player.ate - player.fed
	var tot = 0
	for p in players:
		tot += p.ate
	var kpc = player.ate / tot
	return max(0, ceil(kpm * 800 + ktd * 500 + kpc * 2000))


func end():
	for player in players:
		player.score = make_score(player)
	ScreenManager.load_screen("victory", {'players': players})


func _on_VictoryTimer_timeout():
	end()
