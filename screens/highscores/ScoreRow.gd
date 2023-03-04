extends Node2D

var even_color = Color("008751")
var size

func _ready():
	size = $Background.size


func load_score(place, score):
	$Place.text = "#%d" % place
	$Name.text = score['name']
	$AminalSprite.set_species(score['species'])
	$Score.text = Global.comma_sep(score['score'])
	
	if place %2 == 0:
		for label in [$Place, $Name, $Score]:
			label.add_theme_color_override("font_color", even_color)
		$Outline.color = even_color
