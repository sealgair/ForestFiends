extends Node2D

export (String) var title = "Map"

func _ready():
	$Background.rect_clip_content = true
	$Background/RespawnTiles.visible = false


func get_spawn_points():
	return $Background.get_node("RespawnTiles").get_used_cells()


func get_cell_size():
	return $Background.get_node("TileMap").cell_size


func get_cellv(pos):
	return $Background.get_node("TileMap").get_cellv(pos)
