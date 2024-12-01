extends Node

@export var score_total: int = 0
var highscore: int = 0
var score: String

func _process(delta: float) -> void:
	if score_total >= highscore:
		highscore = score_total
		
	score = "Highscore: " + str(highscore)
