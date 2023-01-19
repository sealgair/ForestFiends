extends "res://screens/Screen.gd"

const ComputerInput = preload("res://main/ComputerInput.gd")

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

static func script_step(start, action, time=0.1):
	return {'start': start, 'action': action, 'time': time, 'done': false}

func basic_script():
	return [
		script_step(0, 'left', 2),
		script_step(3, 'right', 2),
		script_step(5.5, 'left'),
		script_step(6, 'attack'),
		script_step(7, 'special'),
	]

var scripts = {
	'Shrew': basic_script(),
	'Bird': [
		script_step(0, 'left', 2),
		script_step(3, 'right', 2),
		script_step(5.5, 'left'),
		script_step(6, 'attack'),
		script_step(7, 'special'),
		script_step(7, 'left', 1),
		script_step(7.3, 'special'),
		script_step(7.6, 'special'),
		script_step(7.9, 'special'),
		script_step(8.2, 'special'),
		script_step(8.2, 'right'),
		script_step(8.25, 'attack'),
	],
	'Frog': [
		script_step(0, 'left', 2),
		script_step(0.5, 'special', 0.5),
		script_step(2, 'right', 2),
		script_step(2.5, 'special', 0.5),
		script_step(4, 'left'),
		script_step(5, 'attack'),
		script_step(6, 'up', 1),
		script_step(6.2, 'attack'),
		script_step(8, 'attack'),
	],
	'Turt': [
		script_step(0, 'left', 2),
		script_step(3, 'right', 2),
		script_step(5.5, 'left'),
		script_step(6, 'attack', 0.5),
		script_step(7, 'special', 1.5),
	],
	'Wasp': [
		script_step(0, 'left', 1),
		script_step(0.5, 'up', 1),
		script_step(1, 'right', 1),
		script_step(1.5, 'down', 1),
		script_step(4, 'left', 0.25),
		script_step(4, 'up', 0.25),
		script_step(5, 'attack'),
	],
	'Slug': [
		script_step(0, 'left', 1),
		script_step(2, 'right', 1),
		script_step(3, 'left'),
		script_step(4, 'attack'),
		script_step(5, 'special'),
		script_step(6, 'right'),
		script_step(7, 'special'),
		script_step(7, 'attack', 0.5),
	],
	'Spid': [
		script_step(0, 'left', 1),
		script_step(1, 'up', 1),
		script_step(2, 'right', 1),
		script_step(3, 'down', 1),
		script_step(4, 'left', 0.25),
		script_step(5, 'attack'),
		script_step(5.1, 'left', 0.25),
		script_step(5.1, 'special'),
		script_step(6, 'attack'),
		script_step(6, 'right', 0.25),
		script_step(7, 'special'),
		script_step(7.5, 'right', 0.25),
		script_step(7.75, 'up', 0.25),
	],
	'Mant': [
		script_step(0, 'left', 2),
		script_step(2, 'right', 2),
		script_step(4.5, 'left'),
		script_step(5, 'attack', 0.6),
		script_step(6, 'special'),
		script_step(7, 'left', 0.3),
		script_step(8, 'attack', 0.6),
	]
}
var aminal_script

var order
var aminal_index = 0
var input

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
	# todo: make this a node or something
	input._process(delta)
	
	var elapsed = $ContinueTimer.wait_time - $ContinueTimer.time_left
	$Debug.text = "%2.1f" % elapsed
	for key in input.pressed:
		if input.pressed[key] > 0:
			$Debug.text += "\n%s" % key
	for step in aminal_script:
		if not step['done'] and elapsed > step['start']:
			input.press(step['action'], step['time'])
			step['done'] = true


func set_aminal(aminal_type):
	$AminalDetail.clean()
	if aminal != null:
		$AminalDetail.players.empty()
		aminal.queue_free()
	
	input = ComputerInput.new()
	input.set_mappings({
		'attack': 'a',
		'special': 'b'
	})
	
	aminal = $AminalDetail.add_player({
		'species': aminal_type,
		'order': 0,
		'palette': floor(randf() * 4),
		'spawn_point': Vector2(2.5,2.5)
	})
	aminal.input = input
	
	description = join(descriptions[aminal_type])
	$RevealTimer.start()
	$ContinueTimer.start()
	$Title.text = Global.aminal_names[aminal_type]
	
	aminal_script = scripts[aminal_type]


func _on_ContinueTimer_timeout():
	aminal_index += 1
	if aminal_index < order.size():
		set_aminal(order[aminal_index])
	else:
		ScreenManager.load_screen(next_screen)
