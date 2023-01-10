extends Node2D

var started = false
var spinner

func _ready():
	set_start(Vector2())
	set_end(Vector2())


func start_decay():
	$Timer.start()
	started = true
	for body in $Area2D.get_overlapping_bodies():
		if body != spinner:
			body.ensnare(self)


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


func _process(delta):
	if started:
		var opacity = $Timer.time_left / $Timer.wait_time
		$Line2D.modulate = Color(1,1,1,opacity)


func intersection_center(square):
	var square_lines = [
		# top
		[Vector2(square.position.x, square.position.y), 
		 Vector2(square.position.x + square.size.x, square.position.y)],
		# left
		[Vector2(square.position.x, square.position.y), 
		 Vector2(square.position.x, square.position.y + square.size.y)],
		# right
		[Vector2(square.position.x + square.size.x, square.position.y), 
		 Vector2(square.position.x + square.size.x, square.position.y + square.size.y)],
		# bottom
		[Vector2(square.position.x, square.position.y + square.size.y), 
		 Vector2(square.position.x + square.size.x, square.position.y + square.size.y)],
	]
	var intersections = []
	for line in square_lines:
		var intersection = Geometry.segment_intersects_segment_2d(
			$Line2D.points[0],
			$Line2D.points[1],
			line[0], line[1]
		)
		if intersection != null:
			intersections.append(intersection)
	if intersections.size() > 0:
		return Global.center(intersections)
	else:
		return null


func _on_Timer_timeout():
	queue_free()
	for body in $Area2D.get_overlapping_bodies():
		body.desnare(self)


func _on_Area2D_body_entered(body):
	if body != spinner:
		body.ensnare(self)


func _on_Area2D_body_exited(body):
	body.desnare(self)
