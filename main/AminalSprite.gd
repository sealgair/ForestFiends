extends Node2D

var palette = 0
@export var species: String = "Shrew"
var aminal_sprite = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_species(species)

func set_species(new_species):
	species = new_species
	if species in Global.species:
		var instance = Global.species[species].instantiate()
		instance.palette = palette
		set_aminal(instance)

func set_aminal(instance):
	if aminal_sprite != null:
		remove_child(aminal_sprite)
		aminal_sprite.queue_free()
	aminal_sprite = instance.get_node("AnimatedSprite2D").duplicate()
	aminal_sprite.position = Vector2(8,8)
	add_child(aminal_sprite)
	aminal_sprite.visible = true
	aminal_sprite.play("idle")
	for child in aminal_sprite.get_children():
		if child.has_method('play'):
			child.play("idle")

func set_palette(new_palette):
	palette = new_palette
	aminal_sprite.material.set_shader_parameter("palette", palette)
