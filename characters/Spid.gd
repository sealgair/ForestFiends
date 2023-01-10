extends "Player.gd"

var sides
var corners
var base_gravity
var from_side = Vector2(0, 1)
var edge_grab = 3
var was_edge = false
var web = null
var web_offset = null
var web_start = null
var web_scene = preload("res://characters/Web.tscn")


signal make_web(start, end, player)


func _ready():
	sides = [$RightTouch, $LeftTouch, $TopTouch, $BottomTouch]
	corners = [$ULCorner, $URCorner, $BLCorner, $BRCorner]
	base_gravity = gravity
	jumping = true


func get_species():
	return "Spid"
	
	
func get_animation():
	var pressed = axes_pressed()
	var side = side_dir()
	
	$AnimatedSprite.transform.origin = Vector2()
	$AnimatedSprite.rotation_degrees = 0
	if side.x != 0:
		$AnimatedSprite.rotation_degrees = 90
	
	if is_attacking():
		return "attack"
	elif jumping:
		$AnimatedSprite.flip_v = false
		return "jump"
	elif side.x != 0 and side.y != 0:
		if from_side.x != 0:
			$AnimatedSprite.rotation_degrees = 90
			$AnimatedSprite.flip_v = side.x > 0
			$AnimatedSprite.flip_h = side.y > 0
		else:
			$AnimatedSprite.rotation_degrees = 0
			$AnimatedSprite.flip_h = side.x > 0
			$AnimatedSprite.flip_v = side.y < 0
		return "corner"
	elif edge_point().length() < edge_grab:
		var corner = corner_dir()
		$AnimatedSprite.transform.origin = corner * 6
		
		if from_side.x == 0:
			$AnimatedSprite.rotation_degrees = 90
			$AnimatedSprite.flip_v = corner.x > 0
			$AnimatedSprite.flip_h = corner.y > 0
		else:
			$AnimatedSprite.rotation_degrees = 0
			$AnimatedSprite.flip_h = corner.x > 0
			$AnimatedSprite.flip_v = corner.y < 0
				
		return "edge"
	elif (pressed * flip(side)).length() != 0:
		return "walk"
	else:
		return "idle"


func unitize(vec):
	if vec.x != 0:
		vec.x = vec.x / abs(vec.x)
	if vec.y != 0:
		vec.y = vec.y / abs(vec.y)
	return vec


func abs2(vec2):
	return Vector2(abs(vec2.x), abs(vec2.y))


func flip(vec2):
	return Vector2(vec2.y, vec2.x)


func side_dir():
	var touches = Vector2()
	for side in sides:
		if side.get_overlapping_bodies().size() > 0:
			touches += side.get_node("CollisionShape2D").transform.origin
	return unitize(touches)


func corner_count():
	var count = 0
	for corner in corners:
		if corner.get_overlapping_bodies().size() > 0:
			count += 1
	return count


func corner_dir():
	if corner_count() == 1:
		for corner in corners:
			if corner.get_overlapping_bodies().size() > 0:
				return unitize(corner.get_node("CollisionShape2D").transform.origin)
	return Vector2()


func edge_point():
	var corner = corner_dir()
	# find corner point
	var edge = position + corner * size/2  # nearest point
	edge = edge.snapped(size)  # snap to tiles
	edge = edge - position # relative to player
	edge -= size/2 * corner  # back to center
	return edge


func attack_pressed():
	if web == null:
		if not jumping:
			start_web()
	else:
		stop_web(true)


func butt_offset():
	var facing = facing2()
	var butt = Vector2()
	var sides = side_dir()
	if edge_point().length() < edge_grab:
		# edge
		if from_side.x == 0:
			butt.x -= facing.y
		else:
			butt.y += facing.y
		butt *= 12
	elif sides.length() > 1:
		# corner
		butt = flip(abs2(from_side)) * -facing
		butt *= size/2
	else:
		#side
		if sides.x == 0:
			butt.x = -facing.x
		if sides.y == 0:
			butt.y = -facing.x
		butt *= size/2
	return butt


func start_web():
	web = web_scene.instance()
	add_child(web)
	
	web_start = position
	if edge_point().length() <= edge_grab:
#		web_start += edge
		web_offset = corner_dir() * (size * (5.0/8.0))
	else:
		web_offset = side_dir() * size/2
		web_start += butt_offset()


func stop_web(keep=false):
	if keep:
		var start = position
		if edge_point().length() <= edge_grab:
			start += corner_dir() * (size * (5.0/8.0))
		else:
			start += side_dir() * size/2
		emit_signal("make_web", start, web_start + web_offset, self)
	web.queue_free()
	web = null
	web_start = null
	web_offset = null


func update_web():
	# TODO: wrap around map (using transform
	web.set_start(butt_offset())
	web.set_end(web_start - position + web_offset)


func special_pressed():
	if not jumping:
		jumping = true
		var side = side_dir()
		var jump_vel
		if edge_point().length() < edge_grab:
			jump_vel = corner_dir()
		else:
			jump_vel = side
		if side.y == 0:
			jump_vel.y += .5
		velocity += jump_vel * jump_speed


func move(x,y):
	var side = side_dir()
	var corner = corner_dir()
	var edge = edge_point()
	if side.length() == 0 and edge.length() > edge_grab+1:
		jumping = true  # falling really, but who's counting
	
	gravity = base_gravity
	if jumping:
		.move(x,y)
	else:
		gravity = 0
	
		$Debug.text = ""
		if edge.length() < edge_grab:
			if not was_edge:
				velocity = Vector2()
			was_edge = true
			var input_mask = Vector2(
				1 if x == corner.x else 0,
				1 if y == corner.y else 0
			)
			var invert_input_mask = abs2(Vector2(1,1) - input_mask)
			to_velocity = edge * run_speed/2 * invert_input_mask
			to_velocity += corner * input_mask * run_speed
		else:
			was_edge = false
			to_velocity = velocity + side * 10
			if side.x != 0:
				to_velocity.y = y * run_speed

				$AnimatedSprite.flip_v = side.x > 0
				if y != 0:
					$AnimatedSprite.flip_h = y > 0
			
			if side.y != 0:
				to_velocity.x = x * run_speed
				
				$AnimatedSprite.flip_v = side.y < 0
				if x != 0:
					$AnimatedSprite.flip_h = x > 0
			
			if (side.x == 0 or side.y == 0) and corner_count() != 1:
				from_side = side * 1 # copy


func _physics_process(delta):
	if jumping and side_dir().length() != 0:
		jumping = false


func _process(_delta):
	if web != null:
		update_web()
