extends Node3D

@onready var lvl: Label3D = $LvlIndicator
@onready var bloom: GPUParticles3D = $LevelBloom
@onready var anim: AnimationPlayer = $LvlIndicator/AnimationPlayer

func _ready():
	bloom.emitting = true
	anim.play("Fade")
	
func _on_animation_player_animation_finished(anim_name):
	queue_free()
	pass # Replace with function body.
