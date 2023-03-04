extends "res://screens/Screen.gd"

var Cursor = preload("res://screens/character_select/Cursor.tscn")

var cursors = {}
var selectors
var player_selectors

func _ready():
	super()
	selectors = [
		[$Selector1, $Selector2, $Selector3,],
		[$Selector4, $Selector5, $Selector6,],
		[$Selector7, $Selector8, $Selector9,],
	]
	player_selectors = [
		$Player1Selector, 
		$Player2Selector, 
		$Player3Selector, 
		$Player4Selector, 
	]

func duplicate_palette(player_selector):
	for other_selector in player_selectors:
		if other_selector != player_selector \
				and other_selector.species == player_selector.species \
				and other_selector.palette == player_selector.palette:
			return true
	return false

func _process(delta):
	super(delta)
	for row in selectors:
		for cell in row:
			if cell != null:
				cell.highlighted = 0
				cell.selected = 0
	
	for p in range(4):
		var player_selector = player_selectors[p]
		var input = inputs[p]
		
		# x & y are flipped to make the inline definition of 'selectors' look right above
		var dir = input.direction_just_pressed(true)
		
		var cursor = null
		if cursors.has(p):
			cursor = cursors[p]
		if cursor == null:
			if dir.length() > 0:
				cursor = Cursor.instantiate()
				add_child(cursor)
				cursor.set_player(p)
				cursors[p] = cursor
				cursor.position = selectors[0][0].position
				$ForceStartTimer.start()
		else:
			var cell = null
			while cell == null:
				cursor.move(dir)
				cell = selectors[cursor.cell.x][cursor.cell.y]
			cursor.position = cell.position
			if cursor.selected:
				player_selector.set_palette(cursor.palette)
				if dir.length() != 0:
					while duplicate_palette(player_selector):
						cursor.move(dir)
						player_selector.set_palette(cursor.palette)
			
			if input.is_just_pressed('select'):
				if cursor.selected:
					var ready = true
					for c in cursors.values():
						ready = ready && c.selected
					if ready:
						start_game()
				else:
					cursor.set_selected(true)
					player_selector.set_species(cell.species)
					while duplicate_palette(player_selector):
						cursor.move(Vector2(1,0))
						player_selector.set_palette(cursor.palette)
			
			if input.is_just_pressed('cancel'):
				if cursor.selected:
					cursor.set_selected(false)
					player_selector.set_species(null)
				else:
					cursor.queue_free()
					cursors.erase(p)
					# reset timer when cursors go away
					$ContinueTimer.start() 
	
	$ContinueTimer.paused = cursors.size() > 0
	$ForceStartTimer.paused = cursors.size() <= 0
	
	$Countdown.text = ""
	if $ForceStartTimer.time_left <= 5 and not $ForceStartTimer.paused:
		$Countdown.text = String(ceil($ForceStartTimer.time_left))
		

func start_game():
	var start_players = []
	var existing_palettes = {}
	for player in player_selectors:
		if player.species != "":
			var palettes = existing_palettes.get(player.species, [])
			palettes.append(player.palette)
			existing_palettes[player.species] = palettes
	for player in player_selectors:
		var player_data = player.make_player(existing_palettes)
		var palettes = existing_palettes.get(player_data['species'], [])
		palettes.append(player_data['palette'])
		existing_palettes[player_data['species']] = palettes
		start_players.append(player_data)
	
	SceneSwitcher.change_scene_to_file("choose_map", {
		"start_players": start_players
	}, ["quad"])


func _on_ForceStartTimer_timeout():
	for p in cursors.keys():
		var cursor = cursors[p]
		cursor.set_selected(true)
		var cell = selectors[cursor.cell.x][cursor.cell.y]
		player_selectors[p].set_species(cell.species)
	start_game()
