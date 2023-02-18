extends "res://brain/PlayerPath.gd"

func _init(the_player, tilemap: TileMap).(the_player, tilemap):
	pass # just here to preserve the args, apparently

func can_be_node(cell):
	return cell != TileMap.INVALID_CELL

func try_connect_points(from, to):
	if to:
		connect_points(from, to)
	return to != null

func _compute_cost(u, v):
	var cost = ._compute_cost(u, v)
	if cost > 1:
		cost *= 3
	return cost

func check_gap(pos, dir):
	# check across gaps (halfway around map)
	for j in range(0,8):
		for s in [j, -j]:
			for i in range(1,8):
				# go straight first, then try the sides
				var gap_pos = pos + dir * i + Global.perpendicular(dir) * s
				var gap = get_point_exact(gap_pos)
				if gap:
					return gap

func connect_node(point):
	var pos = get_point_position(point)
	for x in [-cell_size.x, 0, cell_size.x]:
		for y in [-cell_size.y, 0, cell_size.y]:
			if (x == 0 or y == 0) and x != y: # only directly adjacent tiles
				var dir = Vector2(x, y)
				var side_pos = pos + dir
				if not try_connect_points(point, get_point_exact(side_pos)):
					try_connect_points(point, check_gap(pos, dir))
