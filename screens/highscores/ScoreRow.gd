extends Node2D

var even_color = Color("008751")
var size

func _ready():
	size = $Background.rect_size


static func comma_sep(n: int) -> String:
	var result := ""
	var i: int = abs(n)

	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000

	return "%s%s%s" % ["-" if n < 0 else "", i, result]


func load_score(place, score):
	$Place.text = "#%d" % place
	$Name.text = score['name']
	$AminalSprite.set_species(score['species'])
	$Score.text = comma_sep(score['score'])
	
	if place %2 == 0:
		for label in [$Place, $Name, $Score]:
			label.add_color_override("font_color", even_color)
		$Outline.color = even_color
