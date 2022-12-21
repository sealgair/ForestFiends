extends Node2D

func _ready():
	randomize()
	var spawn_points = $RespawnTiles.get_used_cells()
	for p in range(Global.players.size()):
		if Global.players[p] != null:
			var s = randi() % spawn_points.size()
			spawn(p, spawn_points[s])
			spawn_points.erase(s)
	

func on_respawn(pl):
	spawn(pl-1)

func spawn(p, spawn_point=null):
	var pl = p+1 # user visible playerlabel
	if Global.players[p] == null:
		return
	if not spawn_point:
		var spawn_points = $RespawnTiles.get_used_cells()
		spawn_point = spawn_points[randi() % spawn_points.size()]
		# TODO: get point furthest from players
	var player = Global.instance_player(p)
	player.set_name("Player{p}".format({'p': pl }))
	player.player = pl
	player.position = spawn_point * player.size
	add_child(player)
	player.connect("respawn", self, "on_respawn")

