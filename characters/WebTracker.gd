extends Object

var start
var offset = Vector2()
var start_transform = Vector2()
var end_transform = Vector2()
var web_scene = preload("res://characters/Web.tscn")
var web


func _init(position, parent):
	start = position
	web = web_scene.instance()
	web.spinner = parent
	web.set_palette(parent.palette)
	parent.add_child(web)
	update(start)

func update(position, butt_offset=Vector2()):
	if web != null:
		web.set_start(start - position + offset + start_transform)
		web.set_end(butt_offset + end_transform)

func queue_free():
	web.queue_free()
	web = null
