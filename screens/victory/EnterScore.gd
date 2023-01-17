extends Node2D

var blink = 1
var time = 0
var letter_index = 0
var score
var aminal
var score_name = "   "
var inputs

var alphabet = " ABCDEFGHIJLKMNOPQRSTUVWXYZ0123456789!"

func _ready():
	set_player(1, "Shrew", 0)


func set_player(p, new_aminal, new_score):
	aminal = new_aminal
	score = new_score
	$Label.text = "Player %d got a high score!\nEnter your name:" % p
	
	inputs = {
		'up': 'ui_up{p}'.format({"p": p}),
		'down': 'ui_down{p}'.format({"p": p}),
		'left': 'ui_left{p}'.format({"p": p}),
		'right': 'ui_right{p}'.format({"p": p}),
		'select': 'ui_a{p}'.format({"p": p}),
		'cancel': 'ui_b{p}'.format({"p": p}),
	}


func _process(delta):
	time += delta
		
	# TODO: lift this into a base class
	var just_pressed = {}
	for btn in inputs.keys():
		just_pressed[btn] = Input.is_action_just_pressed(inputs[btn])
	var dir = Vector2(0,0)
	if just_pressed['left']:
		dir.x -= 1
	if just_pressed['right']:
		dir.x += 1
	if just_pressed['up']:
		dir.y -= 1
	if just_pressed['down']:
		dir.y += 1
		
	if just_pressed['select']:
		if letter_index == 2:
			Global.add_highscore(score_name, aminal, score)
			queue_free()
		else:
			var was = score_name[letter_index]
			letter_index += 1
			score_name[letter_index] = was
			
	if just_pressed['cancel']:
		score_name[letter_index] = ' '
		if letter_index > 0:
			letter_index -= 1
	
	if dir.x != 0:
		var was = score_name[letter_index]
		letter_index = wrapi(letter_index + dir.x, 0, 3)
		if score_name[letter_index] == ' ':
			score_name[letter_index] = was
		time = 0
	if dir.y != 0:
		var letter = score_name[letter_index]
		var letter_at = alphabet.find(letter)
		letter_at = wrapi(letter_at - dir.y, 0, alphabet.length())
		letter = alphabet[letter_at]
		score_name[letter_index] = letter
		time = blink/2.0

	$Name.text = score_name
	if time < blink/2.0:
		$Name.text[letter_index] = '_'
	if time > blink:
		time = 0
