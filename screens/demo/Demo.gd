extends "res://screens/arena/Arena.gd"

const PlayerInput = preload("res://main/PlayerInput.gd")
@export_enum("highscores", "stats", "info") var next_screen: String = "highscores"
var inputs = []

func _ready():
	super()
	for i in range(4):
		var input = PlayerInput.new(i+1)
		input.set_mappings({
			'select': 'a',
			'cancel': 'b'
		})
		inputs.append(input)

func _process(delta):
	super(delta)
	for input in inputs:
		if input.is_any_just_pressed(["select", "cancel"]):
			SceneSwitcher.change_to_scene("select", {}, ["f"])

func hit():
	# don't track hits in demo mode
	pass

func _on_ContinueTimer_timeout():
	SceneSwitcher.change_to_scene(next_screen)
