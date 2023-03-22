extends Node2D

@export var title: String = "Map"
@export var show_score: bool = true

func _ready():
	$Background.clip_contents = true
	$Background/RespawnTiles.visible = false
	$HUD.visible = show_score


func get_spawn_points():
	return $Background/RespawnTiles.get_used_cells(0)


func get_cell_size():
	return $Background/TileMap.tile_set.tile_size


func get_cell(pos):
	return $Background/TileMap.get_cell_source_id(0, pos)
