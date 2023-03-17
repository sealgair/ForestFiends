extends Area2D

var started = false
var spinner = null
var texture = preload("res://art/spid.png")
var decay_max = 20
var decay = decay_max
var shaking = Vector2()
var new_shaking = Vector2()

func _ready():
	set_start(Vector2())
	set_end(Vector2())

func set_palette(palette):
	var image = texture.get_image()
	false # image.lock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	$Line2D.default_color = image.get_pixel(palette, 3)
	false # image.unlock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

func start_decay(time=null):
	if time != null:
		decay = time
	started = true
	for body in get_overlapping_bodies():
		if body != spinner:
			body.ensnare(self)
	if spinner:
		set_palette(spinner.palette)

func get_start():
	return $Line2D.get_point_position(0)

func set_start(point):
	$Line2D.set_point_position(0, point)
	$Collision.shape.a = point
	$Debug.position = point

func get_end():
	return $Line2D.get_point_position(1)

func set_end(point):
	$Line2D.set_point_position(1, point)
	$Collision.shape.b = point

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

func intersection_center(center, radius=8):
	var start = $Line2D.points[0]
	var end = $Line2D.points[1]
	var intersect = Geometry2D.segment_intersects_circle(start, end, center, radius)
	if intersect == -1:
		return null
	else:
		var diff = end - start
		var hyp = diff.length() * intersect
		var angle = atan2(diff.y, diff.x)
		return start + Vector2(cos(angle) * hyp, sin(angle) * hyp)

func end_decay():
	queue_free()
	for body in get_overlapping_bodies():
		if body.has_method('desnare'):
			body.desnare(self)

func _on_Web_body_entered(body):
	if body != spinner and body.has_method('ensnare'):
		if started:
			body.ensnare(self)
		else:
			spinner.stop_web()

func _on_Web_body_exited(body):
	if body != spinner and body.has_method('desnare'):
		body.desnare(self)
