extends Node2D

const PlayerInput = preload("res://main/PlayerInput.gd")

export (String, "highscores", "stats", "info") var next_screen = "highscores"
export (bool) var is_idle_screen = true
var rows = []
var inputs = []

func _ready():
	for i in range(4):
		var input = PlayerInput.new(i+1)
		input.set_mappings({
			'select': 'a',
			'cancel': 'b'
		})
		inputs.append(input)


func _process(delta):
	if rows:
		var revealed = ($RevealTimer.time_left-1) / ($RevealTimer.wait_time-1)
		revealed = 1 - revealed
		revealed = floor(revealed * rows.size())
		for a in range(rows.size()):
			rows[a].visible = a < revealed
	
	if is_idle_screen:
		for input in inputs:
			if input.is_any_just_pressed(["select", "cancel"]):
				ScreenManager.load_screen("select")


func _on_ContinueTimer_timeout():
	ScreenManager.load_screen(next_screen)
