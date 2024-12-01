extends Node3D

@onready var exp: Label3D = $ExpIndicator
@onready var anim: AnimationPlayer = $ExpIndicator/AnimationPlayer

func _ready():
	anim.play("Fade")
	
func _on_animation_player_animation_finished(anim_name):
	queue_free()
	pass # Replace with function body.
