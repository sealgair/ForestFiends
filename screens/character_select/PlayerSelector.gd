extends Node2D

@export var player_order: int = 1
var palette = 0
var species = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(player_order)
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
		var instance = Global.species[new_species].instantiate()
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

func make_player(_existing_palettes):
	return {
		'order': player_order,
		'species': species,
		'palette': palette,
		'computer': species == ""
	}
