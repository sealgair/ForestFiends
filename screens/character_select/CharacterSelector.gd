extends Node2D

@export var highlighted: int = 0
@export var selected: int = 0
@export_enum("Shrew", "Bird", "Frog", "Turt", "Wasp", "Mant", "Slug", "Spid", "Fungus") var species: String


func _ready():
	if species:
		$AminalSprite.set_species(species)
		$Label.text = Global.aminal_names[species]
	else:
		visible = false
