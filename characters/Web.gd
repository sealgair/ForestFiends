extends Node2D


func _ready():
	set_start(Vector2())
	set_end(Vector2())


func set_start(point):
	$Line2D.set_point_position(0, point)
	$Area2D.get_node("CollisionPolygon2D").polygon[0] = point


func set_end(point):
	$Line2D.set_point_position(1, point)
	$Area2D.get_node("CollisionPolygon2D").polygon[1] = point
