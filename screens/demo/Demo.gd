extends "res://screens/arena/Arena.gd"

const PlayerInput = preload("res://main/PlayerInput.gd")
export (String, "highscores", "stats", "info") var next_screen = "highscores"
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
	for input in inputs:
		if input.is_any_just_pressed(["select", "cancel"]):
			ScreenManager.load_screen("select")

func hit():
	# don't track hits in demo mode
	pass


func _on_ContinueTimer_timeout():
	ScreenManager.load_screen(next_screen)
