extends "Player.gd"

const MyceliumTile = preload("res://characters/MyceliumTile.tscn")

var mycelium = {}
var cursor_cell = Vector2()
var bump = Vector2()

func get_species():
	return "Fungus"

func init(start_pos, the_tilemap):
	tilemap = the_tilemap
	start_pos += Vector2(0, tilemap.cell_size.y)
	cursor_cell = Global.floor2(start_pos / tilemap.cell_size)
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

func handle_input(delta):
	var axes = input.direction_just_pressed()
	var new_cursor = cursor_cell + axes
	if new_cursor in mycelium:
		cursor_cell = new_cursor
	elif tilemap.get_cellv(new_cursor) != tilemap.INVALID_CELL:
		bump = axes * tilemap.cell_size / 4
		
	if input.is_pressed('special'):
		var dir = input.direction_pressed()
		if dir.length() == 0:
			dir = Global.sign2(bump)
		if dir.length() > 0:
			spread(dir)

func spread(dir):
	var myc = mycelium[cursor_cell]
	var cell = cursor_cell + dir
	if  myc.can_spread() and tilemap.get_cellv(cell) != tilemap.INVALID_CELL:
		add_myc(cell, -dir)
		myc.grow(-0.2)

func do_physics_process(delta):
	if computer:
		think(delta)
	handle_input(delta)

func do_process(delta):
	for myc in mycelium.values():
		myc.grow(0.2*delta)
	var cursor_pos = cursor_cell * tilemap.cell_size + bump
	var cursor_speed = 64 * delta # pixels per second
	if cursor_pos != $Cursor.transform.origin:
		var diff = cursor_pos - $Cursor.transform.origin
		var move = Global.sign2(diff) * cursor_speed
		move = Global.clamp2(move, -Global.abs2(diff), Global.abs2(diff))
		$Cursor.transform.origin += move
	else:
		bump = Vector2()

func think(delta):
	pass
