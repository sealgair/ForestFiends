extends "Player.gd"

const MyceliumTile = preload("res://characters/MyceliumTile.tscn")

var mycelium = {}
var cursor_cell = Vector2()
var spread_from = cursor_cell

func get_species():
	return "Fungus"

func init(start_pos, the_tilemap):
	tilemap = the_tilemap
	start_pos += Vector2(0, tilemap.cell_size.y)
	cursor_cell = Global.floor2(start_pos / tilemap.cell_size)
	spread_from = cursor_cell
	add_myc(cursor_cell, Vector2(0, -1), 0.75)
	$Cursor.transform.origin = start_pos
	var myc_start = MyceliumTile.instance()

func add_myc(cell, dir, growth=0):
	if cell in mycelium:
		return # already got one
	var myc = MyceliumTile.instance()
	myc.init(dir, growth)
	myc.position = cell * tilemap.cell_size
	mycelium[cell] = myc
	add_child(myc)

func move_cursor(dir):
	var absolute_cursor = cursor_cell + dir
	var new_cursor = Global.wrap2(absolute_cursor, Vector2(), Vector2(16,16))
	if valid_cell(new_cursor) and dir.length() > 0:
		if new_cursor in mycelium:
			cursor_cell = new_cursor
			spread_from = cursor_cell
		elif (spread_from - absolute_cursor).length() < 2:
			cursor_cell = new_cursor
		elif $Cursor.animation == "default":
			$Cursor.play('leave') # blink in place
		return true
	return false

func handle_input(delta):
	var axes = input.direction_just_pressed()
	if axes.length() > 0:
		if not move_cursor(axes):
			# check diagonals
			if axes.x == 0:
				for x in [1,-1]:
					if move_cursor(Vector2(x, axes.y)):
						break
			elif axes.y == 0:
				for y in [1,-1]:
					if move_cursor(Vector2(axes.x, y)):
						break
		
	if input.is_just_pressed('special') and not cursor_cell in mycelium:
		spread(spread_from)

func valid_cell(cell):
	return tilemap.get_cellv(cell) != tilemap.INVALID_CELL

func spread(from):
	var myc = mycelium[from]
	var cell = cursor_cell
	cell = Global.wrap2(cell, Vector2(), Vector2(16,16))
	if myc.can_spread() and valid_cell(cell):
		add_myc(cell, from - cursor_cell)
		myc.grow(-0.2)

func do_physics_process(delta):
	if computer:
		think(delta)
	handle_input(delta)

func do_process(delta):
	for myc in mycelium.values():
		myc.grow(0.2*delta)
	var cursor_pos = cursor_cell * tilemap.cell_size
	if cursor_pos != $Cursor.transform.origin and $Cursor.animation == "default":
		$Cursor.play('leave')

func think(delta):
	pass

func _on_Cursor_animation_finished():
	if $Cursor.animation == "leave": 
		$Cursor.transform.origin = cursor_cell * tilemap.cell_size
		$Cursor.play('enter')
	elif $Cursor.animation == "enter": 
		$Cursor.play('default')
