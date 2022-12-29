extends Node

var species = {
	'Shrew': load("res://characters/Shrew.tscn"),
	'Bird': load("res://characters/Bird.tscn"),
	'Frog': load("res://characters/Frog.tscn"),
	'Turt': load("res://characters/Turt.tscn"),
}
var screens = {
	'select': "res://screens/character_select/CharacterSelect.tscn",
	'play': "res://screens/arena/Map.tscn",
}
var player_colors = [
	Color("ff004d"),
	Color("83769c"),
	Color("00e436"),
	Color("ffa300"),
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
