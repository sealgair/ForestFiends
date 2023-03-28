extends CanvasLayer

const PlayerInput = preload("res://main/PlayerInput.gd")

var items: Array[Node]
var selected = 0
var selected_color = Color("ffa300")
var unselected_color = Color("a28879")
var inputs: Array[PlayerInput]

func _ready():
	get_tree().paused = true
	items = [
		$Resume,
		$Quit,
		$Exit,
#		$Settings,
#		$Credits,
	]
	for i in range(4):
		var input = PlayerInput.new(i+1)
		input.set_mappings({
			'select': 'a',
			'cancel': 'b'
		})
		inputs.append(input)


func _process(_delta):
	for input in inputs:
		if input.is_any_just_pressed(["cancel"]):
			unpause()
			break
		if input.is_any_just_pressed(["select"]):
			var item = items[selected]
			if item == $Resume:
				unpause()
			elif item == $Exit:
				get_tree().quit()
			elif item == $Quit:
				unpause()
				SceneSwitcher.change_to_scene("info")
			break
		var dir = input.direction_just_pressed()
		if dir.y != 0:
			selected = wrapi(selected + dir.y, 0, items.size())
			break # only one player at a time
	
	for i in range(items.size()):
		var item: Label = items[i]
		if i == selected:
			item.add_theme_color_override("font_color", selected_color)
		else:
			item.add_theme_color_override("font_color", unselected_color)
		
	
	if Input.is_action_just_pressed("pause"):
		unpause()

func unpause():
	get_tree().paused = false
	queue_free()
