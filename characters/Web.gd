extends Node2D

var started = false
var spinner
var texture = preload("res://art/spid.png")
var decay_max = 15
var decay = decay_max
var shaking = Vector2()
var new_shaking = Vector2()


func _ready():
	set_start(Vector2())
	set_end(Vector2())


func set_palette(palette):
	var image = texture.get_data()
	image.lock()
	$Line2D.default_color = image.get_pixel(palette, 3)
	image.unlock()


func start_decay():
	started = true
	for body in $Area2D.get_overlapping_bodies():
		if body != spinner:
			body.ensnare(self)
	if spinner:
		set_palette(spinner.palette)


func get_start():
	return $Line2D.get_point_position(0)


func set_start(point):
	$Line2D.set_point_position(0, point)
	$Area2D.get_node("CollisionPolygon2D").polygon[0] = point


func get_end():
	return $Line2D.get_point_position(1)


func set_end(point):
	$Line2D.set_point_position(1, point)
	$Area2D.get_node("CollisionPolygon2D").polygon[1] = point


func shake(direction):
	new_shaking = direction


func _process(delta):
	if started:
		decay -= delta
		if new_shaking.length() != 0 and new_shaking != shaking:
			decay -= delta * 3
			shaking = new_shaking
		if decay <= 0:
			end_decay()
		else:
			var opacity = decay / decay_max
			$Line2D.modulate = Color(1,1,1,opacity)


func intersection_center(square):
	var center = square.position
	var size = square.size/2
	var square_lines = [
		# top
		[Vector2(center.x - size.x, center.y - size.y), 
		 Vector2(center.x + size.x, center.y - size.y)],
		# left
		[Vector2(center.x - size.x, center.y - size.y), 
		 Vector2(center.x - size.x, center.y + size.y)],
		# right
		[Vector2(center.x + size.x, center.y - size.y), 
		 Vector2(center.x + size.x, center.y + size.y)],
		# bottom
		[Vector2(center.x - size.x, center.y + size.y), 
		 Vector2(center.x + size.x, center.y + size.y)],
	]
	var intersections = []
	var web_line = $Line2D.points
	for line in square_lines:
		var intersection = Geometry.segment_intersects_segment_2d(
			web_line[0], web_line[1],
			line[0], line[1]
		)
		if intersection != null:
			intersections.append(intersection)
	if intersections.size() > 0:
		return Global.center(intersections)
	else:
		return null


func end_decay():
	queue_free()
	for body in $Area2D.get_overlapping_bodies():
		body.desnare(self)


func _on_Area2D_body_entered(body):
	if started and body != spinner:
		body.ensnare(self)


func _on_Area2D_body_exited(body):
	body.desnare(self)
