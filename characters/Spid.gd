extends "Player.gd"

var sides
var corners
var from_side = Vector2(0, 1)
var edge_grab = 3
var web_parts = {}
var top_web = null
var WebTracker = preload("res://characters/WebTracker.gd")

signal make_web(start, end, player)

func _ready():
	super()
	sides = [$RightTouch, $LeftTouch, $TopTouch, $BottomTouch]
	corners = [$ULCorner, $URCorner, $BLCorner, $BRCorner]

func init(start_pos, the_tilemap):
	jump_height = 2
	jump_dist = 3
	jumping = true
	PlayerPath = load("res://brain/WaspPath.gd")
	super(start_pos, the_tilemap)

func get_species():
	return "Spid"

func get_long_species():
	return "Spider"

func pronouns():
	return ['she', 'her', 'her', 'hers']
	
func get_animation():
	var pressed = axes_pressed()
	var side = side_dir()
	
	$AnimatedSprite2D.transform.origin = Vector2()
	$AnimatedSprite2D.rotation_degrees = 0
	if side.x != 0:
		$AnimatedSprite2D.rotation_degrees = 90
	
	if is_attacking():
		return "attack"
	elif jumping:
		$AnimatedSprite2D.flip_v = false
		return "jump"
	elif in_corner():
		if from_side.x != 0:
			$AnimatedSprite2D.rotation_degrees = 90
			$AnimatedSprite2D.flip_v = side.x > 0
			$AnimatedSprite2D.flip_h = side.y > 0
		else:
			$AnimatedSprite2D.rotation_degrees = 0
			$AnimatedSprite2D.flip_h = side.x > 0
			$AnimatedSprite2D.flip_v = side.y < 0
		return "corner"
	elif on_edge():
		var corner = corner_dir()
		$AnimatedSprite2D.transform.origin = corner * 3
		
		if from_side.x == 0:
			$AnimatedSprite2D.rotation_degrees = 90
			$AnimatedSprite2D.flip_v = corner.x > 0
			$AnimatedSprite2D.flip_h = corner.y > 0
		else:
			$AnimatedSprite2D.rotation_degrees = 0
			$AnimatedSprite2D.flip_h = corner.x > 0
			$AnimatedSprite2D.flip_v = corner.y < 0
				
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

func on_edge():
	return corner_count() == 1

func in_corner():
	return corner_count() == 3

func attack_pressed():
	if web_parts.size() == 0:
		if not jumping:
			start_web()
			attack_timeout = 0 # no need to wait to stop the web
			brain.will_jump = true
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
		butt = flip(Global.abs2(from_side)) * -facing
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
	var web = WebTracker.new(position, self)
	web_parts[Vector2()] = web
	
	if edge_point().length() <= edge_grab:
		web.offset = corner_dir() * (size * (5.0/8.0))
	else:
		web.offset = side_dir() * size/2
		if corner_count() > 1:
			web.offset += butt_offset()
	top_web = web

func web_end():
	var end = position
	if edge_point().length() <= edge_grab:
		end += corner_dir() * (size * (5.0/8.0))
	else:
		end += side_dir() * size/2
	return end

func stop_web(keep=false):
	if keep:
		for web in web_parts.values():
			emit_signal(
				"make_web", 
				web.start + web.offset + web.start_transform, 
				web_end() + web.end_transform, 
				self)
	for web in web_parts.values():
		web.queue_free()
	web_parts = {}
	top_web = null

func update_web():
	for web in web_parts.values():
		web.update(position, butt_offset())

func wrap_screen(amount):
	super.wrap_screen(amount)
	if web_parts.size() > 0:
		for web in web_parts.values():
			web.end_transform -= amount
		var more_web
		var new_transform = top_web.start_transform + amount
		if web_parts.has(new_transform):
			more_web = web_parts[new_transform]
		else:
			more_web = WebTracker.new(position, self)
			more_web.start = top_web.start
			more_web.offset = top_web.offset
			more_web.start_transform = new_transform
			more_web.end_transform = Vector2()
			web_parts[more_web.start_transform] = more_web
		top_web = more_web

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

func up_dir():
	var side = side_dir()
	if side.length() > 0:
		return -side
	else:
		return super.up_dir()

func move(dir):
	var side = side_dir()
	var corner = corner_dir()
	var edge = edge_point()
	
	if side.length() > 0:
		# stop jumping on touch
		jumping = false
	elif corner_count() == 0 or edge.length() > edge_grab+1:
		jumping = true  # falling really, but who's counting
	
	gravity = base_gravity
	if jumping:
		super.move(dir)
	else:
		if in_corner():
			gravity = Vector2()
		else:
			gravity = base_gravity.length() * side
	
		to_velocity = velocity + side * 10
		if side.x != 0:
			to_velocity.y = dir.y * run_speed

			$AnimatedSprite2D.flip_v = side.x > 0
			if dir.y != 0:
				$AnimatedSprite2D.flip_h = dir.y > 0
		
		if side.y != 0:
			to_velocity.x = dir.x * run_speed
			
			$AnimatedSprite2D.flip_v = side.y < 0
			if dir.x != 0:
				$AnimatedSprite2D.flip_h = dir.x > 0
		
		if (side.x == 0 or side.y == 0) and corner_count() != 1:
			from_side = side * 1 # copy

func die():
	super.die()
	$AnimatedSprite2D.flip_v = false
	$AnimatedSprite2D.rotation_degrees = 0
	gravity = base_gravity

func revive(new_pos):
	super.revive(new_pos)
	jumping = true

func _process(delta):
	super(delta)
	update_web()

func _on_Hit_body_entered(other):
	if not other.dead and other.webs.size() > 0:
		hit(other)

func track_distance(amount):
	super.track_distance(amount)
	if web_parts.size() == 0:
		brain.web_dist -= amount

func init_brain():
	var data = super.init_brain()
	data.attack_accuracy = 1 # gets offset other ways
	data.web_dist = next_web_dist()
	data.web_target = null
	data.will_jump = false
	return data

func next_web_dist():
	return 16 + randf() * 16*4

func opposing_surface():
	var surface = null
	var tile = Global.round2(position / tilemap.cell_size)
	for d in range(1, jump_height+2):
		var next = tile + -side_dir() * d
		if tilemap.get_cell_source_id(0, next) != Global.INVALID_CELL:
			return next
	return null

func should_attack(enemy):
	if not jumping:
		if web_parts.size() > 0:
			# has to cross air
			var airs = 0
			var web = web_parts[Vector2()]
			var start = web.start
			var end = web_end()
			var points = Global.points_on_line(start, end)
			for point in points:
				point = Global.wrap2(point, Vector2(), screen_size)
				var tile = Global.round2(point / cell_size)
				if tilemap.get_cell_source_id(0, tile) == Global.INVALID_CELL:
					airs += 1
					if airs >= 16:
						return true
			
		else:
			brain.web_target = null
			if brain.web_dist <= 0:
				brain.web_dist = next_web_dist()
				return true
	return false

func should_jump(enemy, path=[]):
	if brain.will_jump:
		brain.will_jump = false
		return true
	else:
		return super.should_jump(enemy, path)

func can_be_target(enemy, filter_ops={}):
	var can_be = super.can_be_target(enemy)
	if not filter_ops.get('safe', false):
		can_be = can_be and enemy.webs.size() > 0
	return can_be

func target_position():
	var target = super.target_position()
	if target == null:
		target = safe_spot()
	return target

func move_toward_point(point):
	var dir = point - position
	if dir.length() > 4:
		# wrap around map
		if abs(dir.x) > 16*8:
			dir.x *= -1
		if abs(dir.x) < 2:
			dir.x = 0
		if abs(dir.y) > 16*8:
			dir.y *= -1
		input.press_axis(dir)
		
		var sides = side_dir()
		if sides.x == 0 and abs(dir.y) > 8:
			input.press("special")
		if sides.y == 0 and abs(dir.x) > 8:
			input.press("special")
