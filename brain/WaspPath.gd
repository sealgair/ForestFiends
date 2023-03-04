extends "res://brain/PlayerPath.gd"

func connect_node(point):
	var pos = get_point_position(point)
	for x in [-cell_size.x, 0, cell_size.x]:
		for y in [-cell_size.y, 0, cell_size.y]:
			if x != 0 or y != 0:
				var side_pos = pos + Vector2(x, y)
				var side = get_point_exact(side_pos)
				if x != 0 and y != 0:
					# diagonal requires an adjacent side free too
					var adjacent_x = side_pos - Vector2(x, 0)
					var adjacent_y = side_pos - Vector2(0, y)
					if not get_point_exact(adjacent_x) and not get_point_exact(adjacent_x):
						continue # both sides are unavailable, so we can't go on the diagonal
				if side:
					connect_points(point, side)
