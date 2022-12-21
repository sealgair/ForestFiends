extends Node

var players = [null, null, null, null]
var palettes = [0,0,0,0]
var characters = {
	'Shroo': load("res://characters/Shroo.tscn"),
	'Brid': load("res://characters/Brid.tscn"),
}
var screens = {
	'select': "res://screens/character_select/CharacterSelect.tscn",
	'play': "res://screens/arena/Map.tscn",
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func add_player(index, character, palette=null):
	players[index] = characters[character]
	palettes[index] = palette

func instance_player(index):
	var player = players[index].instance()
	player.palette = palettes[index]
	return player

func remove_player(index):
	players[index] = null
	
func load_scene(named):
	get_tree().change_scene(screens[named])
