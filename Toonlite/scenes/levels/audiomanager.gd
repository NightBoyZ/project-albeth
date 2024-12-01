extends AudioStreamPlayer
@export var bgm: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	bgm[1].loop = true
	play_song(bgm[2])
	pass # Replace with function body.

func play_song(song):
	stream = song
	playing = true
	autoplay = true
