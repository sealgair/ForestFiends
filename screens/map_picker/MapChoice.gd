extends Node2D


export (String, "Basic", "Cave", "Plains", "Mountain", "Desert", "Sky", "Jungle", "Shelf") var map_name = "Basic"
var is_selected = false
var map_scene

func _ready():
	set_map(map_name)


func get_selected():
	return is_selected


func set_selected(selected):
	is_selected = selected
	var color = Color("ffa300" if is_selected else "7e2553")
	$ColorRect.color = color
	$Label.add_color_override("font_color", color)


func set_map(map_name):
	map_scene = load("res://maps/{name}.tscn".format({'name': map_name}))
	var new_map = map_scene.instance()
	new_map.scale = Vector2(0.125, 0.125)
	new_map.set_name("Map")
	var pos = $Map.get_position_in_parent()
	$Map.queue_free()
	add_child(new_map)
	move_child(new_map, pos)
	$Label.text = new_map.title
