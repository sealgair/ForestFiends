extends Node

# TODO: use this
enum Species {
	Shrew,
	Bird,
	Frog,
	Turt,
	Wasp,
	Mant,
	Slug,
	Spid,
	Fungus,
}

const INVALID_CELL = -1
var statsfilename = "user://stats.save"
var highscoresfilename = "user://highscores.save"
var species = {
	'Shrew': preload("res://characters/Shrew.tscn"),
	'Bird': preload("res://characters/Bird.tscn"),
	'Frog': preload("res://characters/Frog.tscn"),
	'Turt': preload("res://characters/Turt.tscn"),
	'Wasp': preload("res://characters/Wasp.tscn"),
	'Mant': preload("res://characters/Mant.tscn"),
	'Slug': preload("res://characters/Slug.tscn"),
	'Spid': preload("res://characters/Spid.tscn"),
	'Fungus': preload("res://characters/Fungus.tscn"),
}
var aminal_names = {
	"Shrew": "Sherm",
	"Bird": "Borb",
	"Frog": "Freg",
	"Turt": "Timt",
	"Wasp": "Wensp",
	"Mant": "Manti",
	"Slug": "Slaul",
	"Spid": "Spid",
	"Fungus": "Mycel",
}
var stats = {}
var highscores = []
var player_colors = [
	Color("ff004d"),
	Color("83769c"),
	Color("00e436"),
	Color("ffa300"),
]


func _init():
	stats = load_stats()
	highscores = load_highscores()


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
	var stat = stats[player.get_species()]
	for key in stat.keys():
		var val = player.get(key)
		if val != null:
			stat[key] += val
	save_stats()


func save_stats():
	var save_file = FileAccess.open(statsfilename, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(stats))
	save_file.close()


func load_stats():
	var file_stats = {}
	if FileAccess.file_exists(statsfilename):
		var save_file = FileAccess.open(statsfilename, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(save_file.get_as_text())
		var data = test_json_conv.get_data()
		if data:
			file_stats = data
		save_file.close()
	for species_name in species.keys():
		if not file_stats.has(species_name):
			file_stats[species_name] = make_stats()
	return file_stats


func check_highscore(score):
	for highscore in highscores:
		if score > highscore['score']:
			return true
	return false


func add_highscore(species_name, aminal, score):
	for i in range(highscores.size()):
		var highscore = highscores[i]
		if score > highscore['score']:
			highscores.insert(i, {
				'name': species_name,
				'species': aminal,
				'score': score,
			})
			break
	highscores = highscores.slice(0, 9)
	save_highscores()


func save_highscores():
	var save_file = FileAccess.open(highscoresfilename, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(highscores))
	save_file.close()


func load_highscores():
	var loaded_scores = []
	if FileAccess.file_exists(highscoresfilename):
		var save_file = FileAccess.open(highscoresfilename, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(save_file.get_as_text())
		var data = test_json_conv.get_data()
		if data:
			loaded_scores = data
		save_file.close()
	if loaded_scores.size() < 1:
		# initialize with example values
		var names = species.keys()
		for i in range(10):
			loaded_scores.append({
				'name': 'ABC',
				'species': names[i % names.size()],
				'score': (10-i)*100
			})
	
	return loaded_scores

func center(points):
	var sum = Vector2()
	for point in points:
		sum += point
	return sum / points.size()


func comma_sep(n: int) -> String:
	var result := ""
	var i: int = abs(n)

	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000

	return "%s%s%s" % ["-" if n < 0 else "", i, result]

func rand_choice(list):
	var i = floor(randf() * list.size())
	return list[i]

func weighted_rand_choice(choices):
	var total = 0
	for weight in choices.values():
		total += weight
	var choose = randf() * total
	var spot = 0
	for option in choices.keys():
		spot += choices[option]
		if spot > choose:
			return option

func perpendicular(vec2):
	return Vector2(vec2.y, vec2.x)

func abs2(vec2):
	return Vector2(abs(vec2.x), abs(vec2.y))

func floor2(vec2):
	return Vector2(
		floor(vec2.x), 
		floor(vec2.y)
	)

func round2(vec2):
	return Vector2(
		int(round(vec2.x)), 
		int(round(vec2.y))
	)

func clamp2(val, low, high):
	return Vector2(
		clamp(val.x, low.x, high.x),
		clamp(val.y, low.y, high.y)
	)

func wrap2(val, low, high):
	return Vector2(
		wrapf(val.x, low.x, high.x),
		wrapf(val.y, low.y, high.y)
	)

func sign2(point):
	return Vector2(sign(point.x), sign(point.y))

func average(values):
	var sum = 0
	for value in values:
		sum += value
	return sum / values.size()

func points_on_line(start, end):
	var points = []
	if start != end:
		var diff = end - start
		if abs(diff.y) < abs(diff.x):
			var slope = diff.y / diff.x
			for x in range(start.x, end.x, sign(diff.x)):
				var y = round(slope * (x - start.x) + start.y)
				points.append(Vector2(x, y))
		else:
			var slope = diff.x / diff.y
			for y in range(start.y, end.y, sign(diff.y)):
				var x = round(slope * (y - start.y) + start.x)
				points.append(Vector2(x, y))
	return points
