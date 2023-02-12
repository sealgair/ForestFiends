extends Node2D

export (int) var highlighted = 0
export (int) var selected = 0
export (String, "Shrew", "Bird", "Frog", "Turt", "Wasp", "Mant", "Slug", "Spid", "Fungus") var species


func _ready():
	if species:
		$AminalSprite.set_species(species)
		$Label.text = Global.aminal_names[species]
	else:
		visible = false
