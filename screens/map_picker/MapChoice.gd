extends Node2D


@export_enum("Basic", "Cave", "Plains", "Mountain", "Desert", "Sky", "Jungle", "Shelf", "Random") var map_name: String = "Basic"
const map_choices = ["Basic", "Cave", "Plains", "Mountain", "Desert", "Sky", "Jungle", "Shelf"]
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
	$Label.add_theme_color_override("font_color", color)


func set_map(new_map_name):
	map_name = new_map_name
	var old_scene = map_scene
	if map_name == "Random":
		while map_scene == old_scene:
			map_scene = load("res://maps/{name}.tscn".format({'name': Global.rand_choice(map_choices)}))
	else:
		map_scene = load("res://maps/{name}.tscn".format({'name': map_name}))
	var new_map = map_scene.instantiate()
	new_map.scale = Vector2(0.125, 0.125)
	new_map.set_name("Map")
	
	var old_map = $Map
	var pos = old_map.get_index()
	remove_child(old_map)
	old_map.queue_free()
	new_map.set_name("Map")
	add_child(new_map)
	move_child(new_map, pos)
	if map_name == "Random":
		$Label.text = map_name
		# load a new scene if we get chosen, it's a different scene than the one displayed
		map_scene = load("res://maps/{name}.tscn".format({'name': Global.rand_choice(map_choices)}))
	else:
		$Label.text = new_map.title


func _on_SwapTimer_timeout():
	if map_name == "Random":
		set_map(map_name)
