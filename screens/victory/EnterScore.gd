extends "res://screens/Screen.gd"

var blink = 1
var time = 0
var letter_index = 0
var score
var aminal
var score_name = "   "

var alphabet = " ABCDEFGHIJLKMNOPQRSTUVWXYZ0123456789"
var input

func _ready():
	set_player(1, "Shrew", 0)


func set_player(p, new_aminal, new_score):
	input = inputs[p-1]
	aminal = new_aminal
	score = new_score
	$Label.text = "Player %d got a high score!\nEnter your name:" % p
	

func _process(delta):
	time += delta
		
	if input.is_just_pressed('select'):
		if letter_index == 2:
			Global.add_highscore(score_name, aminal, score)
			queue_free()
		else:
			var was = score_name[letter_index]
			letter_index += 1
			score_name[letter_index] = was
			
	if input.is_just_pressed('cancel'):
		score_name[letter_index] = ' '
		if letter_index > 0:
			letter_index -= 1
	
	var dir = input.direction_just_pressed()
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
