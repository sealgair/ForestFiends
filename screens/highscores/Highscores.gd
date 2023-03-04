extends "res://screens/Screen.gd"

const ScoreRow = preload("res://screens/highscores/ScoreRow.tscn")

func _ready():
	super()
	var scores = Global.highscores
	for i in range(scores.size()):
		var score = scores[i]
		var score_row = ScoreRow.instantiate()
		score_row.load_score(i+1, score)
		add_child(score_row)
		score_row.transform.origin.y = 24 + i * score_row.size.y
		rows.append(score_row)

