extends Node

var stafilename = "user://stats.save"
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
var stats = {}
var screens = {
	'stats': "res://screens/stats/Stats.tscn",
	'select': "res://screens/character_select/CharacterSelect.tscn",
	'play': "res://screens/arena/Map.tscn",
}
var player_colors = [
	Color("ff004d"),
	Color("83769c"),
	Color("00e436"),
	Color("ffa300"),
]


func _init():
	stats = load_stats()


func make_stats():
	return {
		'score': 0,
		'ate': 0,
		'fed': 0,
		'wins': 0,
		'losses': 0,
		'time': 0,
		'distance': 0
	}


func add_player_stats(player):
	var stat = stats[player.gets_species()]
	for key in stat.keys():
		var val = player.get(key)
		if val != null:
			stat[key] += val
	save_stats()


func save_stats():
	var save_file = File.new()
	save_file.open(stafilename, File.WRITE)
	save_file.store_string(to_json(stats))
	save_file.close()


func load_stats():
	var file_stats = {}
	var save_file = File.new()
	if save_file.file_exists(stafilename):
		save_file.open(stafilename, File.READ)
		var data = parse_json(save_file.get_as_text())
		if data:
			file_stats = data
		save_file.close()
	for name in species.keys():
		if not file_stats.has(name):
			file_stats[name] = make_stats()
	return file_stats


func center(points):
	var sum = Vector2()
	for point in points:
		sum += point
	return sum / points.size()
