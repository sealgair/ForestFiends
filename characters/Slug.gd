extends "Player.gd"

signal make_slime(position, palette)

var spikes

func _ready():
	attack_anim = "none"
	attack_offset = Vector2(0,0)
	spikes = [$Spike1, $Spike2, $Spike3]
	for spike in spikes:
		spike.material.set_shader_param("palette", palette)


func get_species():
	return "Slug"


func slime():
	pass


func is_mobile():
	return not Input.is_action_pressed(inputs['attack'])


func special_pressed():
	slimed = slime_time
	velocity.x = run_speed * 2
	if $AnimatedSprite.flip_h:
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
		if not found:
			# make one
			emit_signal("make_slime", slime_pos, palette)
	
	
	# extend spikes
	var an = attackNode.get_ref()
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
		if is_attack_pressed():
			an.extend()