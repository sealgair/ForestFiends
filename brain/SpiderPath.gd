extends "res://brain/PlayerPath.gd"


func connect_node(point):
	# ground
	super.connect_node(point)
	
	var pos = get_point_position(point)
	
	# ceiling
	var above = get_point_exact(pos - Vector2(0, cell_size.y))
	if above == null:
		for x in [cell_size.x, -cell_size.x]:
			var side_pos = pos + Vector2(x, 0)
			var side = get_point_exact(side_pos)
			if side:
				connect_points(point, side)
	
	# walls
	for x in [cell_size.x, -cell_size.x]:
		var side_pos = pos + Vector2(x, 0)
		var side = get_point_exact(side_pos)
		# TODO?
