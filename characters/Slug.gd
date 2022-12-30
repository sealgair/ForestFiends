extends "Player.gd"


func _ready():
	attack_anim = "none"
	attack_offset = Vector2(0,0)

func get_species():
	return "Slug"


func _process(delta):
	._process(delta)

	var an = attackNode.get_ref()
	$Spike1.visible = an != null
	$Spike2.visible = an != null
	$Spike3.visible = an != null
	if an:
		var l = easeoutback(an.life/an.live)
		an.scale = Vector2(l+1, l+1)
		l *= 8
		$Spike1.transform.origin.y = -l
		$Spike2.transform.origin.x = -l
		$Spike3.transform.origin.x = l
		
