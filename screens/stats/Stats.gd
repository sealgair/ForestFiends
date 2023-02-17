extends "res://screens/Screen.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	rows = [
		$Shrew,
		$Bird,
		$Frog,
		$Turt,
		$Wasp,
		$Mant,
		$Slug,
		$Spid,
		$Fungus,
	]
	for aminal in rows:
		var stats = Global.stats[aminal.name]
		aminal.get_node("Ate").text = String(stats['ate'])
		aminal.get_node("Fed").text = String(stats['fed'])
		aminal.get_node("Won").text = String(stats['wins'])
		aminal.get_node("Lost").text = String(stats['losses'])
		var time = int(stats['time'])
		var hours = floor(time / 3600)
		var minutes = floor((time % 3600) / 60)
		var seconds = time % 60
		var timestring = ""
		if hours > 0:
			timestring = "%d:" % hours
		timestring += "%02d:%02d" % [minutes, seconds]
		aminal.get_node("Time").text = timestring
