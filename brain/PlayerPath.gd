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
	map_dimensions = Vector2(tilemap.cell_quadrant_size, tilemap.cell_quadrant_size)
	cell_size = tilemap.cell_size
	
	# make points
	for y in range(map_dimensions.y):
		for x in range(map_dimensions.x):
			var point = Vector2(x, y)
			var cell = tilemap.get_cellv(point)
			if cell == tilemap.INVALID_CELL:  
				# invalid cells are the air we can move through
				var id = get_available_point_id()
				add_point(id, point)
	
	# make connections
	for point in get_points():
		var pos = get_point_position(point)
		var below = get_point_exact(pos + Vector2(0, 1))
		if below == null:
			# grounded
			for x in [1, -1]:
				var side = get_point_exact(pos + Vector2(x, 0))
				if side:
					connect_points(point, side)
				# TODO: jumping over gaps
				# TODO: jumping up ledges
		else:
			# falling
			connect_points(point, below, false)
	
	# update points to map coords
	map_dimensions *= cell_size
	var offset = cell_size / 2  # so coords are at center of tile
	for point in get_points():
		var pos = get_point_position(point)
		pos = pos * cell_size + offset
		set_point_position(point, pos)

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

func path_to_enemy(enemy):
	var point_a = get_closest_point(player.position)
	var point_b = get_closest_point(enemy.position)
	var path = get_point_path(point_a, point_b)
	while path.size() == 0:
		var pos = get_point_position(point_b)
		point_b = get_point_exact(pos + Vector2(0, cell_size.y))
		if point_b == null:
			break
		else:
			path = get_point_path(point_a, point_b)
		
	return path

func distance_between(a, b):
	var dist = 0
	var prev = null
	var path = path_between(a, b)
	for point in path:
		if prev != null:
			dist += wrap_dist(point, prev)
		prev = point
	return dist
