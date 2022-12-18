extends Node2D

export (int) var players = 2

var Player = load("res://Brid.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var spawn_points = $RespawnTiles.get_used_cells()
	for p in range(players):
		var s = randi() % spawn_points.size()
		spawn(p+1, spawn_points[s])
		spawn_points.erase(s)
	

func spawn(p, spawn_point=null):
	if not spawn_point:
		var spawn_points = $RespawnTiles.get_used_cells()
		spawn_point = spawn_points[randi() % spawn_points.size()]
		# TODO: get point furthest from players
	var player = Player.instance()
	player.set_name("Player{p}".format({'p': p }))
	player.player = p
	player.position = spawn_point * player.size
	add_child(player)
	player.connect("respawn", self, "spawn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
