extends Node2D

var palette = 0
export (String, "Shrew", "Bird", "Frog", "Turt", "Wasp", "Mant", "Slug", "Spid", "Fungus") var species = "Shrew"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_species(species)

func set_species(new_species):
	species = new_species
	if species in Global.species:
		var instance = Global.species[species].instance()
		instance.palette = palette
		set_aminal(instance)

func set_aminal(instance):
	var aminal_sprite = instance.get_node("AnimatedSprite")
	while ($AnimatedSprite.frames.get_frame_count("idle") > 0):
		$AnimatedSprite.frames.remove_frame("idle", 0)
	for f in range(aminal_sprite.frames.get_frame_count("idle")):
		var frame = aminal_sprite.frames.get_frame("idle", f)
		$AnimatedSprite.frames.add_frame("idle", frame)
	if instance.palette != palette and instance.palette != null:
		set_palette(instance.palette)
	$AnimatedSprite.play("idle")

func set_palette(new_palette):
	palette = new_palette
	$AnimatedSprite.material.set_shader_param("palette", palette)
