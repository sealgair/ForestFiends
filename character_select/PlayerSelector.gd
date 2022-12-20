extends Node2D

export (int) var player = 1
var palette = null
var aminal = ""
var colors = [
	Color("ff004d"),
	Color("83769c"),
	Color("00e436"),
	Color("00e436"),
]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = String(player)
	$Background.color = colors[player-1]

func set_aminal(new_aminal):
	aminal = new_aminal
	if aminal:
		var instance = load("res://characters/{a}.tscn".format({"a": aminal})).instance()
		var aminal_sprite = instance.get_node("AnimatedSprite")
		for f in range($Aminal.frames.get_frame_count("idle")):
			$Aminal.frames.remove_frame("idle", f)
		for f in range(aminal_sprite.frames.get_frame_count("idle")):
			var frame = aminal_sprite.frames.get_frame("idle", f)
			$Aminal.frames.add_frame("idle", frame)
		
		$Label.visible = false
		$Sky.visible = true
		$Aminal.visible = true
		$Aminal.play("idle")
	else:
		$Aminal.visible = false
		$Sky.visible = false
		$Label.visible = true

