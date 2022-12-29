extends Node

var species = {
	'Shroo': load("res://characters/Shroo.tscn"),
	'Brid': load("res://characters/Brid.tscn"),
	'Forg': load("res://characters/Forg.tscn"),
	'Trut': load("res://characters/Trut.tscn"),
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
