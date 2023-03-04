extends "res://screens/Screen.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
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
		aminal.get_node("Ate").text = str(stats['ate'])
		aminal.get_node("Fed").text = str(stats['fed'])
		aminal.get_node("Won").text = str(stats['wins'])
		aminal.get_node("Lost").text = str(stats['losses'])
		var time = int(stats['time'])
		var hours = floor(time / 3600.0)
		var minutes = floor((time % 3600) / 60.0)
		var seconds = time % 60
		var timestring = ""
		if hours > 0:
			timestring = "%d:" % hours
		timestring += "%02d:%02d" % [minutes, seconds]
		aminal.get_node("Time").text = timestring
