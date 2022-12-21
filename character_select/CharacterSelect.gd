extends Node2D

var inputs = {}
var highlights = [null, null, null, null]
var selections = [false, false, false, false]
var selectors
var players

func _ready():
	selectors = [
		[$Selector1, $Selector3,],
	]
	players = [
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
			players[p].shift_palette(sign(dir.length()))
		elif dir.length() != 0:
			if cell == null:
				cell = Vector2(0,0)
				highlights[p] = cell
			else:
				cell.x = wrapi(cell.x+dir.x, 0, selectors.size())
				cell.y = wrapi(cell.y+dir.y, 0, selectors[cell.x].size())
			highlights[p] = cell
		
		if cell != null:
			players[p].visible = true
			selectors[cell.x][cell.y].highlighted |= int(pow(2,p))
			if Input.is_action_just_pressed(inp['select']):
				selections[p] = true
			if selections[p]:
				selectors[cell.x][cell.y].selected |= int(pow(2,p))
				players[p].set_aminal(selectors[cell.x][cell.y].aminal)
			
			if Input.is_action_just_pressed(inp['cancel']):
				if selections[p]:
					selections[p] = false
					players[p].set_aminal("")
				else:
					highlights[p] = null
		else:
			players[p].visible = false
		
		
		
