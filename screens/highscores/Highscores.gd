extends Node2D

var ScoreRow = preload("res://screens/highscores/ScoreRow.tscn")
var rows = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var scores = Global.highscores
	for i in range(scores.size()):
		var score = scores[i]
		var score_row = ScoreRow.instance()
		score_row.load_score(i+1, score)
		add_child(score_row)
		score_row.transform.origin.y = 24 + i * score_row.size.y
		rows.append(score_row)


func _process(delta):
	var revealed = ($RevealTimer.time_left-1) / ($RevealTimer.wait_time-1)
	revealed = 1 - revealed
	revealed = floor(revealed * rows.size())
	for i in range(rows.size()):
		rows[i].visible = i < revealed


func _on_ContinueTimer_timeout():
	ScreenManager.load_screen("stats")
