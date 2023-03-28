extends Node2D

const PlayerInput = preload("res://main/PlayerInput.gd")
const PauseMenu = preload("res://main/PauseMenu.tscn")

@export_enum("highscores", "stats", "info", "demo") var next_screen: String = "highscores"
@export var is_idle_screen:bool = true
@export var transitions: Array[String] = ["fall", "diagonal", "swipe"]
@export var transition_direction: Vector2 = Vector2(0,0)
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
	$StartPrompt.visible = is_idle_screen

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		var pause = PauseMenu.instantiate()
		add_child(pause)
	
	if rows:
		var revealed = ($RevealTimer.time_left-1) / ($RevealTimer.wait_time-1)
		revealed = 1 - revealed
		revealed = floor(revealed * rows.size())
		for a in range(rows.size()):
			rows[a].visible = a < revealed
	
	if is_idle_screen:
		for input in inputs:
			if input.is_any_just_pressed(["select", "cancel"]):
				change_scene_to_file("select")
				

func _on_ContinueTimer_timeout():
	change_scene_to_file()

func change_scene_to_file(next=null, params={}):
	if next == null:
		next = next_screen
	SceneSwitcher.change_to_scene(next, params, transitions, transition_direction)
