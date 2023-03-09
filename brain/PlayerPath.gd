extends AStar2D

var player
var cell_size
var map_dimensions = Vector2i(16, 16)

static func absmin(vals):
	var found = null
	for val in vals:
		if found == null or abs(val) < abs(found):
			found = val
	return found

func wrapp(pos):
	return Vector2i(
		wrapi(pos.x, 0, map_dimensions.x),
		wrapi(pos.y, 0, map_dimensions.y)
	)

func _init(the_player,tilemap: TileMap):
	player = the_player
	cell_size = tilemap.tile_set.tile_size
	map_dimensions = Vector2i(tilemap.cell_quadrant_size, tilemap.cell_quadrant_size) * cell_size
	
	# make points
	build_nodes(tilemap)
	
	# make connections
	for point in get_point_ids():
		connect_node(point)

func can_be_node(cell):
	# invalid cells are the air we can move through
	return cell == Global.INVALID_CELL

func build_nodes(tilemap):
	var offset = cell_size / 2  # so coords are at center of tile
	for y in range(tilemap.cell_quadrant_size):
		for x in range(tilemap.cell_quadrant_size):
			var point = Vector2i(x, y)
			var cell = tilemap.get_cell_source_id(0, point)
			if can_be_node(cell):
				var id = get_available_point_id()
				add_point(id, point * cell_size + offset)

func connect_node(point):
	var pos = get_point_position(point)
	var below_pos = pos + Vector2(0, cell_size.y)
	var below = get_point_exact(below_pos)
	if below == null:
		# grounded
		for x in [cell_size.x, -cell_size.x]:
			var side_pos = pos + Vector2(x, 0)
			var side = get_point_exact(side_pos)
			if side:
				connect_points(point, side)
				# gotta make oe side doesn't have ground under it
				if get_point_exact(side_pos + Vector2(0, cell_size.y)) != null:
					# jumping over gaps
					for i in range(player.jump_dist):
						var jump_pos = pos + Vector2((i+1)*x, 0)
						var jump_to = get_point_exact(jump_pos)
						if jump_to != null:
							var jump_on = get_point_exact(jump_pos + Vector2(0, cell_size.y))
							if jump_on == null:
								connect_points(side, jump_to)
								break
					# TODO: jump over gaps with height differences
			else:
				# look up to see if we can jump
				for i in range(1, player.jump_height):
					var jump_pos = side_pos - Vector2(0, i*cell_size.y)
					var jump_point = get_point_exact(jump_pos)
					if jump_point != null:
						connect_points(point, jump_point)
						break
						
		# jumping
		for i in range(1, player.jump_height):
			var jump_pos = pos - Vector2(0, i*cell_size.y)
			var jump_point = get_point_exact(jump_pos)
			if jump_point != null:
				connect_points(point, jump_point)
			
	else:
		# falling
		connect_points(point, below, false)
		# fall diagonally
		for x in [cell_size.x, -cell_size.x]:
			var side = get_point_exact(pos + Vector2(x, 1))
			var side_below = get_point_exact(below_pos + Vector2(x, 1))
			if side and side_below:
				# needs to be an empty space above if we're gonna move while falling
				connect_points(point, side_below, false)
	

func get_point_exact(pos: Vector2):
	pos = wrapp(pos)
	var nearest = get_closest_point(pos)
	if get_point_position(nearest) == pos:
		return nearest
	else:
		return null

func wrap_dist(posa, posb):
	var diff = posa - posb
	var extent = map_dimensions / 2
	diff.x = wrapf(diff.x, -extent.x, extent.x)
	diff.y = wrapf(diff.y, -extent.y, extent.y)
	return diff.length()

func _compute_cost(u, v):
	var posa = get_point_position(u)
	var posb = get_point_position(v)
	return wrap_dist(posa, posb)

func _estimate_cost(u, v):
	return _compute_cost(u, v)

func path_between(a, b):
	var point_a = get_closest_point(a)
	var point_b = get_closest_point(b)
	return get_point_path(point_a, point_b)

func ground_below(point, _breadth=1, _step=1):
	var pos = get_point_position(point)
	var below = ground_below_pos(pos)
	return get_point_exact(below)
	
func ground_below_pos(pos, breadth=1, step=1):
	"""
	Breadth-first recursive check of points below that given in a cone
	shape, to find the highest ground it might land on
	"""
	var pos_below = pos + Vector2(0, cell_size.y)
	pos_below.y = wrapi(pos_below.y, 0, map_dimensions.y)
	# breadth-first check of nodes below current (directly and to both sides)
	for b in range(breadth+1):
		for x in [b * cell_size.x, -b * cell_size.x]:
			var pos_beside = pos_below + Vector2(x, 0)
			pos_beside.x = wrapi(pos_beside.x, 0, map_dimensions.x)
			if get_point_exact(pos_beside) == null:
				return pos
	# nothing found at this level, check the next level
	return ground_below_pos(pos_below, breadth+step, step)

func player_position():
	return player.think_position()

func path_to_enemy(enemy):
	var point_a = get_closest_point(player_position())
	var point_b = get_closest_point(enemy.position)
	if point_b:
		point_b = ground_below(point_b)
		return get_point_path(point_a, point_b)

func distance_to_enemy(enemy):
	return path_distance(path_to_enemy(enemy))

func distance_between(a, b):
	return path_distance(path_between(a, b))

func path_distance(path):
	var dist = 0
	var prev = null
	for point in path:
		if prev != null:
			dist += wrap_dist(point, prev)
		prev = point
	return dist
