extends Node2D

export (int) var highlighted = 0
export (int) var selected = 0
export (String, "Shrew", "Bird", "Frog", "Turt", "Wasp", "Mant", "Slug", "Spid") var species

var names = {
	"Shrew": "Sherm",
	"Bird": "Borb",
	"Frog": "Freg",
	"Turt": "Timt",
	"Wasp": "Wensp",
	"Mant": "Manti",
	"Slug": "Slaul",
	"Spid": "Spid",
}

func _ready():
	if species:
		$AminalSprite.set_species(species)
		$Label.text = names[species]
	else:
		visible = false
