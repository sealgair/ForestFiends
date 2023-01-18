extends "res://screens/Screen.gd"

var aminal
var descriptions = {
	'Shrew': [
		"A speedy little guy.",
		"Attack: he bites!",
		"Special: a quick lunge and turn.",
		"    (good for getting behind your prey)"
	],
	'Bird': [
		"Quite a flappy one, that.",
		"Attack: a peck, or a dive from the air.",
		"Special: flaps those wings."
	],
	'Frog': [
		"A jumpy little dude with some reach. Not much of a walker, though.",
		"Attack: a long and dangerous tongue.",
		"    (press up & down to aim with the fly.)",
		"Special: jump, hold to jump further.",
	],
	'Turt': [
		"What? I like turtles.",
		"Attack: a bite. (My, what a long neck you have.)",
		"Special: retreat. No one can penetrate your shell, but you won't do much good tucked away in there."
	],
	'Wasp': [
		"She can buzz through the air.",
		"Attack: A sting, while not immediately fatal, could prove dangerous without the cure.",
		"Special: What, flying's not enough?"
	],
	'Slug': [
		"Slippery, slimy, and spiky. Leaves trails of slick slime.",
		"Attack: Spikes. All over.",
		"Special: You can slip too!"
	],
	'Spid': [
		"Creepy. Crawly. On the walls, or upside-down.",
		"Attack: spin a web. If you catch something, make sure to go back for your snack.",
		"Special: leaps and bounds."
	],
	'Mant': [
		"A sneaky feller if there ever was one.",
		"Attack: hold until its charged, release to slash.",
		"    Good things come to those who wait.",
		"Special: hide. Until you strike, that is."
	]
}
var description = ""
var order
var aminal_index = 0


static func join(lines):
	var result = ""
	for line in lines:
		result += line + "\n"
	return result


func _ready():
	order = descriptions.keys()
	randomize()
	order.shuffle()
	set_aminal(order[aminal_index])


func _process(delta):
	var revealed = ($RevealTimer.time_left-1) / ($RevealTimer.wait_time-1)
	revealed = 1 - revealed
	revealed = floor(revealed * description.length())
	$Description.text = description.substr(0, revealed)


func set_aminal(aminal_type):
	if aminal != null:
		aminal.queue_free()
	aminal = Global.species[aminal_type].instance()
	aminal.scale = Vector2(2,2)
	aminal.init(Vector2(128, 96))
	add_child(aminal)
	description = join(descriptions[aminal_type])
	$RevealTimer.start()
	$ContinueTimer.start()
	$Title.text = Global.aminal_names[aminal_type]


func _on_ContinueTimer_timeout():
	aminal_index += 1
	if aminal_index < order.size():
		set_aminal(order[aminal_index])
	else:
		ScreenManager.load_screen(next_screen)
