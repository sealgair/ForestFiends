extends "res://brain/PlayerPath.gd"

func _init(the_player, tilemap: TileMap).(the_player, tilemap):
	pass # just here to preserve the args, apparently

func connect_node(point):
	var pos = get_point_position(point)
	for x in [-cell_size.x, 0, cell_size.x]:
		for y in [-cell_size.y, 0, cell_size.y]:
			if x != 0 or y != 0:
				var side_pos = pos + Vector2(x, y)
				var side = get_point_exact(side_pos)
				if side:
					connect_points(point, side)
