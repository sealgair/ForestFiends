extends "Player.gd"

const MyceliumTile = preload("res://characters/MyceliumTile.tscn")
const Mushroom = preload("res://characters/Mushroom.tscn")

var mycelium = {}
var mushrooms = {}
var cursor_cell = Vector2()
var spread_from = cursor_cell
var growth = 0.2
var attack_hint = Vector2(0,-1)


func get_species():
	return "Fungus"

func init(start_pos, the_tilemap):
	tilemap = the_tilemap
	start_pos += Vector2(0, tilemap.cell_size.y)
	cursor_cell = Global.floor2(start_pos / tilemap.cell_size)
	spread_from = cursor_cell
	add_myc(cursor_cell, Vector2(0, -1), 0.75)
	$Cursor.position = start_pos
	$Cursor.material.set_shader_param("palette", palette)
	var myc_start = MyceliumTile.instance()

func add_myc(cell, dir, growth=0):
	if cell in mycelium:
		return # already got one
	var myc = MyceliumTile.instance()
	myc.init(dir, growth, palette)
	myc.position = cell * tilemap.cell_size
	mycelium[cell] = myc
	add_child(myc)
	move_child(myc, 0)

func add_mushroom(cell, dir):
	var mush = Mushroom.instance()
	mush.init(dir, palette)
	mush.position = cell * tilemap.cell_size
	mushrooms[cell] = mush
	add_child(mush)
	mush.connect("die", self, "remove_mushroom")
	mush.connect("fed", self, "die")

func remove_mushroom(mush):
	for key in mushrooms.keys():
		if mushrooms[key] == mush:
			mushrooms.erase(key)
	mush.queue_free()

func can_move(dir):
	var absolute_cursor = cursor_cell + dir
	var new_cursor = Global.wrap2(absolute_cursor, Vector2(), Vector2(16,16))
	return ground_cell(new_cursor) and dir.length() > 0

func move_cursor(dir):
	var absolute_cursor = cursor_cell + dir
	var new_cursor = Global.wrap2(absolute_cursor, Vector2(), Vector2(16,16))
	if ground_cell(new_cursor) and dir.length() > 0:
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
	var dir = input.direction_just_pressed()
	if dir.length() != 0:
		if dir.length() > 1: # both keys
			dir.x = 0
		$Cursor/Hint.rotation = dir.angle() + TAU/4
		attack_hint = dir
	
	# TODO: hold direction to go faster
	if dir.length() > 0 and not input.is_pressed('attack'):
		if not can_move(dir):
			# check diagonals (but only if there's nothing in between)
			if dir.x == 0:
				for x in [1,-1]:
					if not can_move(Vector2(x, 0)) and can_move(Vector2(x, dir.y)):
						dir = Vector2(x, dir.y)
						break
			elif dir.y == 0:
				for y in [1,-1]:
					if not can_move(Vector2(0, y)) and can_move(Vector2(dir.x, y)):
						dir = Vector2(dir.x, y)
						break
		move_cursor(dir)
		
	if input.is_just_pressed('special') and not cursor_cell in mycelium:
		spread(spread_from)
		
	if input.is_just_released('attack'):
		if cursor_cell in mycelium:
			sprout()

func ground_cell(cell):
	return tilemap.get_cellv(cell) != tilemap.INVALID_CELL

func spread(from):
	var myc = mycelium[from]
	var cell = cursor_cell
	cell = Global.wrap2(cell, Vector2(), Vector2(16,16))
	if myc.can_spread() and ground_cell(cell):
		add_myc(cell, from - cursor_cell)
		myc.grow(-growth)
		spread_from = cursor_cell

func sprout():
	var myc = mycelium[cursor_cell]
	if myc.growth < 0.8:
		return false
	var options = []
	for side in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
		var pos = cursor_cell+side
		if ground_cell(pos):
			continue
		# filter based on keys pressed
		if attack_hint.x != 0 and side.x != attack_hint.x:
			continue
		if attack_hint.y != 0 and side.y != attack_hint.y:
			continue
		options.append(side)
	if options.size() > 0:
		var dir = Global.rand_choice(options)
		var pos = cursor_cell+dir
		if pos in mushrooms:
			var mush = mushrooms[pos]
			for player in mush.burst():
				if player.has_method('infect'):
					player.infect(self)
		else:
			add_mushroom(pos, dir)
			myc.growth = 0.2
		return true
	return false

func die():
	fed += 1

func do_draw():
	pass

func do_physics_process(delta):
	if computer:
		think(delta)
	handle_input(delta)

func do_process(delta):
	for myc in mycelium.values():
		myc.grow(growth*delta)
	var cursor_pos = cursor_cell * tilemap.cell_size
	if cursor_pos != $Cursor.position and $Cursor.animation == "default":
		$Cursor.play('leave')
	for mpos in mushrooms.keys():
		if mushrooms[mpos].done:
			mushrooms.erase(mpos)

func think(delta):
	pass

func _on_Cursor_animation_finished():
	if $Cursor.animation == "leave": 
		$Cursor.position = cursor_cell * tilemap.cell_size
		$Cursor.play('enter')
	elif $Cursor.animation == "enter": 
		$Cursor.play('default')
