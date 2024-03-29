extends Node2D

var start_data = [
	{'order': 1, 'species': "", 'palette': 0, 'computer': true},
	{'order': 2, 'species': "", 'palette': 0, 'computer': true},
	{'order': 3, 'species': "", 'palette': 0, 'computer': true},
	{'order': 4, 'species': "", 'palette': 0, 'computer': true},
]
var players = []
@export var score_limit: int = 30
@export var max_computers: int = 4
@export var countdown: bool = true
var score = 0
var victory_time = 0
var victory_time_max = 15
var victory_sprites = []
var victory_dead = []
var victory_scores = []
var victory_ate = []
var victory_fed = []

var slime_scene = preload("res://characters/Slime.tscn")
var web_scene = preload("res://characters/Web.tscn")
var map_scene = null

const MapChoice = preload("res://screens/map_picker/MapChoice.tscn")
const NullInput = preload("res://main/NullInput.gd")

func _ready():
	var root_vp = get_tree().get_root()
	$LeftWrap/Viewport.world_2d = root_vp.world_2d
	$LeftWrap/Viewport.canvas_transform.origin.x = -256
	$RightWrap/Viewport.world_2d = root_vp.world_2d
	$RightWrap/Viewport.canvas_transform.origin.x = 32
	$TopWrap/Viewport.world_2d = root_vp.world_2d
	$TopWrap/Viewport.canvas_transform.origin.y = -256
	$BottomWrap/Viewport.world_2d = root_vp.world_2d
	$BottomWrap/Viewport.canvas_transform.origin.y = 32
	root_vp.transparent_bg = true
	
	$VictoryOverlay.visible = false
	victory_sprites = [
		$VictoryOverlay/Player1,
		$VictoryOverlay/Player2,
		$VictoryOverlay/Player3,
		$VictoryOverlay/Player4,
	]
	victory_dead = [
		$VictoryOverlay/Death1,
		$VictoryOverlay/Death2,
		$VictoryOverlay/Death3,
		$VictoryOverlay/Death4,
	]
	victory_scores = [
		[
			$VictoryOverlay/Score11,
			$VictoryOverlay/Score21,
			$VictoryOverlay/Score31,
			$VictoryOverlay/Score41,
		],
		[
			$VictoryOverlay/Score12,
			$VictoryOverlay/Score22,
			$VictoryOverlay/Score32,
			$VictoryOverlay/Score42,
		],
		[
			$VictoryOverlay/Score13,
			$VictoryOverlay/Score23,
			$VictoryOverlay/Score33,
			$VictoryOverlay/Score43,
		],
		[
			$VictoryOverlay/Score14,
			$VictoryOverlay/Score24,
			$VictoryOverlay/Score34,
			$VictoryOverlay/Score44,
		],
	]
	victory_ate = [
		$VictoryOverlay/Ate1,
		$VictoryOverlay/Ate2,
		$VictoryOverlay/Ate3,
		$VictoryOverlay/Ate4,
	]
	victory_fed = [
		$VictoryOverlay/Fed1,
		$VictoryOverlay/Fed2,
		$VictoryOverlay/Fed3,
		$VictoryOverlay/Fed4,
	]
	
	if countdown:
		get_tree().paused = true
	else:
		$Countdown.visible = false
	if map_scene == null:
		var map_name = Global.rand_choice(MapChoice.instantiate().map_choices)
		map_scene = load("res://maps/{name}.tscn".format({'name': map_name}))
	set_map(map_scene.instantiate())
	
	randomize()
	$Map/HUD/Score.text = str(score_limit)
	var spawn_points = $Map.get_spawn_points()
	var species_choices = {
		'Shrew': 3,
		'Slug': 1,
		'Turt': 2,
		'Wasp': 1,
		'Bird': 3,
		'Frog': 2,
		'Mant': 1,
		'Spid': 1,
		'Fungus': 0.5,
	}
	
	var existing_palettes = {}
	for player_data in start_data:
		if not player_data.computer:
			var palettes = existing_palettes.get(player_data.species, [])
			palettes.append(player_data.palette)
			existing_palettes[player_data.species] = palettes
	
	var computers = 0
	for player_data in start_data:
		if player_data.computer and computers < max_computers:
			computers += 1
			var overrides = {
#				1: 'Shrew',
#				2: 'Shrew',
#				3: 'Shrew',
#				4: 'Shrew',
			}
			if computers in overrides:
				player_data.species = overrides[computers]
			else:
				player_data.species = Global.weighted_rand_choice(species_choices)
			var palette = randi() % 4
			var species_palettes = existing_palettes.get(player_data.species, [])
			while palette in species_palettes:
				palette = wrapi(palette+1, 0, 4)
			player_data.palette = palette
			species_palettes.append(palette)
			existing_palettes[player_data.species] = species_palettes
		
		if player_data.species:
			var sp = spawn_points[randi() % spawn_points.size()]
			spawn_points.erase(sp)
			player_data.spawn_point = Vector2(sp)
			add_player(player_data)
	
	# populate enemies lists after all players are created
	#  (otherwise they'll be missing some)
	for player in players:
		player.make_enemies(players)
		

func _process(delta):
	var count = floor($CountdownTimer.time_left)
	
	if count > 0:
		$Countdown.text = "%d..." % count
	else:
		$Countdown.text = "START!"
		
	if victory_time > 0:
		Engine.time_scale = victory_time / victory_time_max
		# unscale time for timer so it still counts in real time
		victory_time -= delta / Engine.time_scale
		if victory_time <= 0:
			Engine.time_scale = 1
			next_scene()
		var opacity = min(victory_time_max - victory_time, 1)
		$VictoryOverlay.modulate = Color(1,1,1,opacity)
	else:
		Engine.time_scale = 1
	
func set_map(new_map):
	var old_map = $Map
	var pos = old_map.get_index()
	remove_child(old_map)
	old_map.queue_free()
	new_map.set_name("Map")
	new_map.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(new_map)
	move_child(new_map, pos)

func add_player(player_data):
	var player = Global.species[player_data['species']].instantiate()
	player.order = player_data['order']
	player.palette = player_data['palette']
	player.computer = player_data['computer']
	player.init(player_data['spawn_point'] * player.size, $Map/Background/TileMap)
	$Map.add_child(player)
	player.respawn.connect(spawn)
	player.made_hit.connect(hit)
	player.make_slime.connect(do_make_slime)
	player.make_web.connect(make_web)
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
		$Map/HUD/Score.text = "0"
		finish()
	else:
		$Map/HUD/Score.text = str(score_limit - score)

func spawnpoint_distance(spawnpoint):
	var distances = []
	for player in players:
		distances.append((player.position - Vector2(spawnpoint)).length())
	return Global.average(distances)

func spawnpoint_sorter(a, b):
	return spawnpoint_distance(a) > spawnpoint_distance(b)

func spawn(player, spawn_point=null):
	if victory_time > 0:
		return # game is ending, don't respawn
	var webs = get_webs()
	if spawn_point == null:
		var furthest = null
		# find spawn point furthest from other players
		for sp in $Map.get_spawn_points():
			sp *= $Map.get_cell_size()
			var webbed = false
			for web in webs:
				if web.intersection_center(sp, 12):
					webbed = true
					break
			if not webbed:
				var dist = spawnpoint_distance(sp)
				if furthest == null or furthest < dist:
					furthest = dist
					spawn_point = sp
	player.revive(spawn_point)

func do_make_slime(slime_pos, palette=0):
	if $Map != null:
		var tile_pos = slime_pos / Vector2($Map.get_cell_size())
		tile_pos.x = round(tile_pos.x-0.1)
		tile_pos.y = ceil(tile_pos.y)
		var tile_id = $Map.get_cell(tile_pos)
		if tile_id != Global.INVALID_CELL:
			var instance = slime_scene.instantiate()
			instance.transform.origin = tile_pos * Vector2($Map.get_cell_size())
			instance.set_palette(palette)
			$Map.add_child(instance)

func get_webs():
	var webs = []
	for child in get_children():
		if child.get_groups().has("webs"):
			webs.append(child)
	return webs

func make_web(start, end, player, decay=null):
	var web = web_scene.instantiate()
	web.spinner = player
	$Map.add_child(web)
	web.set_start(start)
	web.set_end(end)
	web.start_decay(decay)

func make_score(player):
	# kills per second
	var kps = player.ate / player.time
	kps *= 1200
	# kill to death
	var ktd = max(0, player.ate - player.fed)
	ktd *= 200
	# percent of total
	var tot = 0
	for p in players:
		tot += p.ate
	var kpc = player.ate / tot
	kpc *= 1000
	return ceil(kps + ktd + kpc) + player.ate * 100

func finish():
	victory_time = victory_time_max
	
	# disable input
	for p in range(players.size()):
		var player = players[p]
		player.computer = false
		player.set_input(NullInput.new(null))
		
		# set up overlay
		victory_sprites[p].set_aminal(player)
		victory_dead[p].set_aminal(player, "dead")
		victory_ate[p].text = str(player.ate)
		victory_fed[p].text = str(player.fed)
		for o in range(players.size()):
			victory_scores[o][p].text = str(player.ate_player[o])
	
	# show overlay
	$VictoryOverlay.visible = true
	

func next_scene():
	for player in players:
		player.score = make_score(player)
	SceneSwitcher.change_to_scene("victory", {'players': players}, ["circle"], Vector2(0,1))

func _on_CountdownTimer_timeout():
	$Countdown.visible = false
	get_tree().paused = false
