extends Node2D

var palette: int = 0
@export var species: String = "Shrew"
var aminal_sprite: AnimatedSprite2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_species(species)

func set_species(new_species):
	species = new_species
	if species in Global.species:
		var instance = Global.species[species].instantiate()
		instance.palette = palette
		set_aminal(instance)

func set_aminal(instance, anim="idle"):
	if aminal_sprite != null:
		remove_child(aminal_sprite)
		aminal_sprite.queue_free()
	aminal_sprite = instance.get_node("AnimatedSprite2D").duplicate(Node.DUPLICATE_USE_INSTANTIATION)
	aminal_sprite.flip_h = false
	aminal_sprite.flip_v = false
	aminal_sprite.modulate = Color(1,1,1,1)
	for node in aminal_sprite.get_children():
		if 'flip_h' in node:
			node.flip_h = false
		if 'transform' in node:
			aminal_sprite.transform.origin.x = 0
	aminal_sprite.position = Vector2(8,8)
	add_child(aminal_sprite)
	aminal_sprite.visible = true
	aminal_sprite.play(anim)
	for child in aminal_sprite.get_children():
		child.offset = Vector2()
		if child.has_method('play'):
			child.play(anim)

func set_palette(new_palette):
	palette = new_palette
	aminal_sprite.material.set_shader_parameter("palette", palette)
