extends "Player.gd"

signal make_slime(position, palette)

var spikes
var max_hold = 1.5
var holding = 0

func _ready():
	attack_anim = "none"
	attack_offset = Vector2(0,4)
	spikes = [$Spike1, $Spike2, $Spike3]
	for spike in spikes:
		spike.material.set_shader_param("palette", palette)


func get_species():
	return "Slug"


func slime():
	pass


func is_mobile():
	return not input.is_pressed('attack')


func special_pressed():
	slimed = slime_time
	velocity.x = run_speed * 2
	if not $AnimatedSprite.flip_h:
		velocity.x *= -1


func _process(delta):
	._process(delta)
	
	# drop slimes
	if is_on_floor():
		# find slime locale
		var slime_pos = self.position + Vector2(-self.size.x/2, self.size.y/2)
		slime_pos = slime_pos.snapped(self.size)
		var found = false
		# check if slime is there already
		for area in $SlimeFinder.get_overlapping_areas():
			if area.collision_layer & 8:
				area.refresh()
				if area.transform.origin == slime_pos:
					found = true
					break
		if not found:
			# make one
			emit_signal("make_slime", slime_pos, palette)
	
	# extend spikes
	var an = attack_node.get_ref()
	for spike in spikes:
		spike.visible = an != null
	if an:
		var l = easeoutback(an.life/an.live)
		an.scale = Vector2(1+l, 1+l)
		l *= 10
		spikes[0].transform.origin.y = -l
		spikes[1].transform.origin.x = -l
		spikes[2].transform.origin.x = l
		
		# hold attack to keep spikes out
		if not dead and is_attack_pressed():
			if holding <= max_hold:
				holding += delta 
				an.extend()
	if dead or not is_attack_pressed():
		holding = 0


func should_special(enemy, next=null):
	var dv = Global.abs2(position - enemy.position)
	if dv.y < 16:
		if dv.x < 16*4 and dv.x > 16:
			return true
	return false
