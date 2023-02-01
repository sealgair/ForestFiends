extends AStar2D

var player
var cell_size
var map_dimensions = Vector2(16, 16)

static func floor2(vec2):
	return Vector2(floor(vec2.x), floor(vec2.y))

static func absmin(vals):
	var found = null
	for val in vals:
		if found == null or abs(val) < abs(found):
			found = val
	return found

func wrapp(pos):
	return Vector2(
		wrapi(pos.x, 0, map_dimensions.x),
		wrapi(pos.y, 0, map_dimensions.y)
	)

func _init(the_player, tilemap: TileMap):
	player = the_player
	cell_size = tilemap.cell_size
	map_dimensions = Vector2(
		tilemap.cell_quadrant_size, 
		tilemap.cell_quadrant_size
	) * cell_size
	
	build_nodes(tilemap)
	
	# make connections
	for point in get_points():
		connect_node(point)

func build_nodes(tilemap):
	var offset = cell_size / 2  # so coords are at center of tile
	for y in range(tilemap.cell_quadrant_size):
		for x in range(tilemap.cell_quadrant_size):
			var pos = Vector2(x, y)
			var cell = tilemap.get_cellv(pos)
			if cell == tilemap.INVALID_CELL:  
				# invalid cells are the air we can move through
				var id = get_available_point_id()
				pos = pos * cell_size + offset
				add_point(id, pos)

func connect_node(point):
	var pos = get_point_position(point)
	var below = get_point_exact(pos + Vector2(0, cell_size.y))
	if below == null:
		# grounded
		for x in [cell_size.x, -cell_size.x]:
			var side_pos = pos + Vector2(x, 0)
			var side = get_point_exact(side_pos)
			if side:
				connect_points(point, side)
				# gotta make sure side doesn't have ground under it
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
			# TODO: jumping up ledges
	else:
		# falling
		connect_points(point, below, false)

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

func ground_below(point, breadth=1, step=1):
	"""
	Breadth-first recursive check of points below that given in a cone
	shape, to find the highest ground it might land on
	"""
	var pos = get_point_position(point)
	var pos_below = pos + Vector2(0, cell_size.y)
	pos_below.y = wrapi(pos_below.y, 0, map_dimensions.y)
	# breadth-first check of nodes below current (directly and to both sides)
	for b in range(breadth+1):
		for x in [b * cell_size.x, -b * cell_size.x]:
			var pos_beside = pos_below + Vector2(x, 0)
			pos_beside.x = wrapi(pos_beside.x, 0, map_dimensions.x)
			var check_point = get_point_exact(pos_beside)
			if check_point == null:
				return point
	# nothing found at this level, check the next level
	return ground_below(get_point_exact(pos_below), breadth+step, step)

func path_to_enemy(enemy):
	var point_a = get_closest_point(player.position)
	var point_b = get_closest_point(enemy.position)
	point_b = ground_below(point_b)
	return get_point_path(point_a, point_b)

func distance_to_enemy(enemy):
	var dist = 0
	var prev = null
	var path = path_to_enemy(enemy)
	for point in path:
		if prev != null:
			dist += wrap_dist(point, prev)
		prev = point
	return dist

func distance_between(a, b):
	var dist = 0
	var prev = null
	var path = path_between(a, b)
	for point in path:
		if prev != null:
			dist += wrap_dist(point, prev)
		prev = point
	return dist
