extends "Player.gd"

const MyceliumTile = preload("res://characters/MyceliumTile.tscn")
const Mushroom = preload("res://characters/Mushroom.tscn")

var mycelium = {}
var mushrooms = {}
var cursor_cell = Vector2()
var growth = 0.2
var cursor_dir = Vector2(0,-1)
var held_dir = Vector2()
var held_dir_time = 0

func get_species():
	return "Fungus"

func init(start_pos, the_tilemap):
	tilemap = the_tilemap
	start_pos += Vector2(0, tilemap.cell_size.y)
	cursor_cell = Global.floor2(start_pos / tilemap.cell_size)
	add_myc(cursor_cell, Vector2(0, -1), 0.75)
	$Cursor.position = start_pos
	$Cursor.material.set_shader_param("palette", palette)
	var myc_start = MyceliumTile.instance()

func damage_myc(cell, amount=0.6):
	if cursor_cell == cell:
		return  # cursor protects mycelium
	var myc = mycelium[cell]
	myc.grow(-amount)
	if myc.growth <= 0:
		remove_child(myc)
		mycelium.erase(cell)
		myc.queue_free()

func add_myc(cell, dir, growth=0):
	if cell in mycelium:
		return # already got one
	for enemy in enemies:
		if 'mycelium' in enemy and cell in enemy.mycelium:
			enemy.damage_myc(cell)
			return # occupied
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
	mush.fungus = self
	mushrooms[cell] = mush
	add_child(mush)
	mush.connect("die", self, "remove_mushroom")
	mush.connect("fed", self, "die")

func remove_mushroom(mush):
	for key in mushrooms.keys():
		if mushrooms[key] == mush:
			mushrooms.erase(key)
	mush.queue_free()

func wrap_cell(cell):
	return Global.wrap2(cell, Vector2(), Vector2(16,16))

func move_cursor(dir):
	if dir.length() > 0:
		var new_cursor = wrap_cell(cursor_cell + dir)
		if ground_cell(new_cursor):
			if new_cursor in mycelium:
				return new_cursor
			elif $Cursor.animation == "default":
				$Cursor.play('leave') # blink in place
		elif dir == cursor_dir:
			# check across gaps (halfway around map)
			for j in range(0,8):
				for s in [j, -j]:
					for i in range(1,8):
						# go straight first, then try the sides
						var skip_cursor = wrap_cell(
							cursor_cell + dir * i + Global.perpendicular(dir) * s
						)
						if skip_cursor in mycelium:
							return skip_cursor
	return cursor_cell

func handle_input(delta):
	# holding the same direct
	var hdir = input.direction_pressed()
	if hdir != held_dir:
		held_dir = hdir
		held_dir_time = 0
	elif hdir.length() > 0:
		held_dir_time += delta
	
	var dir = input.direction_just_pressed()
	if held_dir_time > 0.3:
		dir = held_dir
	if dir.length() != 0:
		if dir.length() > 1: # both keys
			dir.x = 0
		
		if dir.length() > 0 and not input.is_pressed('attack'):
			var new = move_cursor(dir)
			track_distance((new-cursor_cell).length() * 16)
			cursor_cell = new
		
		$Cursor/Hint.rotation = dir.angle() + TAU/4
		cursor_dir = dir
		held_dir_time = 0
		
	if input.is_just_pressed('special') or input.is_just_released('attack'):
		if spread():
			specials += 1
		
		if cursor_cell in mycelium:
			sprout()

func ground_cell(cell):
	return tilemap.get_cellv(cell) != tilemap.INVALID_CELL

func spread():
	var myc = mycelium[cursor_cell]
	var cell = cursor_cell + cursor_dir
	cell = Global.wrap2(cell, Vector2(), Vector2(16,16))
	if myc.can_spread() and ground_cell(cell):
		add_myc(cell, -cursor_dir)
		myc.grow(-growth)
		return true
	return false

func sprout():
	var myc = mycelium[cursor_cell]
	if myc.growth < 0.2:
		return
	var options = []
	for side in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
		var pos = cursor_cell+side
		if ground_cell(pos):
			continue
		# filter based on keys pressed
		if cursor_dir.x != 0 and side.x != cursor_dir.x:
			continue
		if cursor_dir.y != 0 and side.y != cursor_dir.y:
			continue
		options.append(side)
	if options.size() > 0:
		var dir = Global.rand_choice(options)
		var pos = cursor_cell+dir
		if pos in mushrooms:
			var mush = mushrooms[pos]
			if mush.burst():
				attacks += 1
				myc.growth -= growth
				# spread to new tiles
				var spread = mush.spore_tile(tilemap)
				if spread:
					add_myc(spread, -mush.facing)
		elif myc.growth > 0.8:
			add_mushroom(pos, dir)
			myc.growth = 0.2

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
