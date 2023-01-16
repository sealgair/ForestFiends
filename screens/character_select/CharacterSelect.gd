extends Node2D

var Cursor = preload("res://screens/character_select/Cursor.tscn")

var inputs = {}
var cursors = {}
var selectors
var player_selectors


func _ready():
	selectors = [
		[$Selector1, $Selector2, $Selector3,],
		[$Selector4, null, $Selector6,],
		[$Selector7, $Selector8, $Selector9,],
	]
	player_selectors = [
		$Player1Selector, 
		$Player2Selector, 
		$Player3Selector, 
		$Player4Selector, 
	]
	for p in range(4):
		var pl = p+1
		inputs[p] = {
			'up': 'ui_up{p}'.format({"p": pl}),
			'down': 'ui_down{p}'.format({"p": pl}),
			'left': 'ui_left{p}'.format({"p": pl}),
			'right': 'ui_right{p}'.format({"p": pl}),
			'select': 'ui_a{p}'.format({"p": pl}),
			'cancel': 'ui_b{p}'.format({"p": pl}),
		}


func _process(delta):
	for row in selectors:
		for cell in row:
			if cell != null:
				cell.highlighted = 0
				cell.selected = 0
	
	for p in range(4):
		var player_selector = player_selectors[p]
		var just_pressed = {}
		var dir = Vector2(0,0)
		for btn in inputs[p].keys():
			just_pressed[btn] = Input.is_action_just_pressed(inputs[p][btn])
		
		# x & y are flipped to make the inline definition of 'selectors' look right above
		if just_pressed['left']:
			dir.y -= 1
		if just_pressed['right']:
			dir.y += 1
		if just_pressed['up']:
			dir.x -= 1
		if just_pressed['down']:
			dir.x += 1
		
		var cursor = null
		if cursors.has(p):
			cursor = cursors[p]
		if cursor == null:
			if dir.length() > 0:
				cursor = Cursor.instance()
				add_child(cursor)
				cursor.set_player(p)
				cursors[p] = cursor
				cursor.position = selectors[0][0].position
		else:
			var cell = null
			while cell == null:
				cursor.move(dir)
				cell = selectors[cursor.cell.x][cursor.cell.y]
			cursor.position = cell.position
			player_selector.set_palette(cursor.palette)
		
			if just_pressed['select']:
				if cursor.selected:
					var ready = true
					for c in cursors.values():
						ready = ready && c.selected
					if ready:
						start_game()
				else:
					cursor.set_selected(true)
					player_selector.set_species(cell.species)
			
			if just_pressed['cancel']:
				if cursor.selected:
					cursor.set_selected(false)
					player_selector.set_species(null)
				else:
					cursor.queue_free()
					cursors.erase(p)
					# reset timer when cursors go away
					$ContinueTimer.start() 
	$ContinueTimer.paused = cursors.size() > 0

func start_game():
	var start_players = []
	for p in cursors.keys():
		var player = player_selectors[p]
		start_players.append(player.make_player())
	
	ScreenManager.load_screen("play", {
		"start_data": start_players
	})


func _on_ContinueTimer_timeout():
	ScreenManager.load_screen("stats")
