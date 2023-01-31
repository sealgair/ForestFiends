extends Node2D

export (int) var player_order = 1
var palette = 0
var species = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = String(player_order)
	$Background.color = Global.player_colors[player_order-1]
	$AminalSprite.visible = false
	$Sky.visible = false
	$Label.visible = true

func set_palette(new_palette):
	palette = new_palette
	$AminalSprite.set_palette(palette)

func set_species(new_species):
	if new_species == null:
		set_aminal(null)
	else:
		var instance = Global.species[new_species].instance()
		set_aminal(instance)

func set_aminal(instance):
	if instance:
		species = instance.get_species()
		$AminalSprite.set_aminal(instance)
		$AminalSprite.visible = true
		$Sky.visible = true
		$Label.visible = false
	else:
		species = ""
		$AminalSprite.visible = false
		$Sky.visible = false
		$Label.visible = true

func make_player(existing_palettes):
	if species == "":
		# player hasn't chosen, use computer
		var species = Global.rand_choice(['Shrew', 'Slug', 'Turt']) # TODO: pick less used first?
		var palette = floor(randf() * 4)
		while palette in existing_palettes.get(species, []):
			palette = wrapi(palette+1, 0, 4)
		return {
			'order': player_order,
			'species': species,
			'palette': palette,
			'computer': true
		}
	else:	
		return {
			'order': player_order,
			'species': species,
			'palette': palette,
			'computer': false
		}
	
