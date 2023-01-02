extends Node2D

export (int) var highlighted = 0
export (int) var selected = 0
export (String, "Shrew", "Bird", "Frog", "Turt", "Wasp", "Mant", "Slug", "Spid") var species

var player_sprites

var names = {
	"Shrew": "Sherm",
	"Bird": "Borb",
	"Frog": "Freg",
	"Turt": "Tirt",
	"Wasp": "Wups",
	"Mant": "Manti",
	"Slug": "Saulg",
	"Spid": "Spids",
}

func _ready():
	player_sprites = [
		$Player1,
		$Player2,
		$Player3,
		$Player4,
	]
	if species:
		$AminalSprite.set_species(species)
		$Label.text = names[species]
	else:
		visible = false

func _process(delta):
	for p in range(4):
		player_sprites[p].animation = "off"
		var mask = int(pow(2, p))
		if highlighted & mask:
			player_sprites[p].animation = "highlight"
		if selected & mask:
			player_sprites[p].animation = "select"
