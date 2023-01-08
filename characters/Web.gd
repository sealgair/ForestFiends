extends Node2D

var started = false

func _ready():
	set_start(Vector2())
	set_end(Vector2())


func start_decay():
	$Timer.start()
	started = true


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


func _on_Timer_timeout():
	queue_free()
