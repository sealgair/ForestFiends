extends Node2D

var players = []
export (int) var score_limit = 2
var score = 0


func _ready():
	randomize()
	$Score.text = String(score_limit)
	var spawn_points = $RespawnTiles.get_used_cells()
	for player in players:
		var s = randi() % spawn_points.size()
		player.init(spawn_points[s] * player.size)
		spawn_points.erase(s)
		add_child(player)
		player.connect("respawn", self, "spawn")
		player.connect("made_hit", self, "hit")
	

func hit():
	score = 0
	for player in players:
		score += player.ate
	
	if score >= score_limit:
		$VictoryTimer.start()
	else:
		$Score.text = String(score_limit - score)


func spawn(player, spawn_point=null):
	if not spawn_point:
		var spawn_points = $RespawnTiles.get_used_cells()
		spawn_point = spawn_points[randi() % spawn_points.size()]
		# TODO: get point furthest from players
	player.revive(spawn_point * player.size)

		
func make_points(player):
	# TODO:
	#local kpm = player.kills / (self.gametime/60)
	#local ktd = player.kills - player.deaths
	#local kpc = player.kills / self.totalkills
	#return max(0, ceil(kpm * 800 + ktd * 500 + kpc * 2000))
	return player.ate * 5 - player.fed * 2


func end():
	for player in players:
		player.points = make_points(player)
	ScreenManager.load_screen("victory", {'players': players})


func _on_VictoryTimer_timeout():
	end()
