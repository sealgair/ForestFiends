extends Node2D

var aminals

# Called when the node enters the scene tree for the first time.
func _ready():
	aminals = [
		$Shrew,
		$Bird,
		$Frog,
		$Turt,
		$Wasp,
		$Mant,
		$Slug,
		$Spid
	]
	for aminal in aminals:
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


func _process(delta):
	var revealed = ($RevealTimer.time_left-1) / ($RevealTimer.wait_time-1)
	revealed = 1 - revealed
	revealed = floor(revealed * aminals.size())
	for a in range(aminals.size()):
		aminals[a].visible = a < revealed
		
	for p in range(4):
		var input_a = 'ui_a{p}'.format({"p": p+1})
		var input_b = 'ui_b{p}'.format({"p": p+1})
		if Input.is_action_just_pressed(input_a) or Input.is_action_just_pressed(input_b):
			ScreenManager.load_screen("select")


func _on_ContinueTimer_timeout():
	ScreenManager.load_screen("select")
