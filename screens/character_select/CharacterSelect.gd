extends Node2D

var inputs = {}
var highlights = [null, null, null, null]
var selections = [false, false, false, false]
var selectors
var player_selectors

func _ready():
	selectors = [
		[$Selector1, $Selector2, $Selector3,],
		[$Selector4,],
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
			cell.highlighted = 0
			cell.selected = 0
	
	for p in range(4):
		var inp = inputs[p];
		var dir = Vector2(0,0)
		# x & y are flipped to make the inline definition of 'selectors' look right above
		if Input.is_action_just_pressed(inp['left']):
			dir.y -= 1
		if Input.is_action_just_pressed(inp['right']):
			dir.y += 1
		if Input.is_action_just_pressed(inp['up']):
			dir.x -= 1
		if Input.is_action_just_pressed(inp['down']):
			dir.x += 1
			
		var cell = highlights[p]
		if selections[p]:
			player_selectors[p].shift_palette(sign(dir.x - dir.y))
		elif dir.length() != 0:
			if cell == null:
				cell = Vector2(0,0)	
				highlights[p] = cell
			else:
				cell.x = wrapi(cell.x+dir.x, 0, selectors.size())
				cell.y = wrapi(cell.y+dir.y, 0, selectors[cell.x].size())
			highlights[p] = cell
		
		if cell != null:
			player_selectors[p].visible = true
			selectors[cell.x][cell.y].highlighted |= int(pow(2,p))
			if Input.is_action_just_pressed(inp['select']):
				if selections[p]:
					var ready = true
					for op in range(4):
						if highlights[op] and not selections[op]:
							ready = false
							break
					if ready:
						start_game()
				else:
					selections[p] = true
			if selections[p]:
				selectors[cell.x][cell.y].selected |= int(pow(2,p))
				player_selectors[p].set_species(selectors[cell.x][cell.y].species)
			
			if Input.is_action_just_pressed(inp['cancel']):
				if selections[p]:
					selections[p] = false
					player_selectors[p].set_aminal(null)
				else:
					highlights[p] = null
		
		
func start_game():
	var start_players = []
	for p in range(selections.size()):
		if selections[p]:
			var player = player_selectors[p]
			start_players.append(player.make_player())
	
	ScreenManager.load_screen("play", {
		"start_data": start_players
	})
