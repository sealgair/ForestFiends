extends Node

var species = {
	'Shrew': load("res://characters/Shrew.tscn"),
	'Bird': load("res://characters/Bird.tscn"),
	'Frog': load("res://characters/Frog.tscn"),
	'Turt': load("res://characters/Turt.tscn"),
	'Wasp': load("res://characters/Wasp.tscn"),
	'Mant': load("res://characters/Mant.tscn"),
	'Slug': load("res://characters/Slug.tscn"),
	'Spid': load("res://characters/Spid.tscn"),
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
