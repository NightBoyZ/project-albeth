extends Node3D

@onready var dmg: Label3D = $DamageIndicator
@onready var spark: GPUParticles3D = $HitSpark
@onready var dmg_anim: AnimationPlayer = $DamageIndicator/AnimationPlayer

@export var rand_x: float = randf_range(-0.2, 0.2)
@export var rand_z: float = randf_range(-0.2, 0.2)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if int(dmg.text) > 5:
		dmg.text += "!"
		dmg_anim.play("Crit")
	else:
		dmg_anim.play("Damage")
	pass # Replace with function body.
	
func _process(delta):
	position.x += rand_x
	position.z += rand_z
	rand_x = lerp(rand_x, 0.0, 0.1)
	rand_z = lerp(rand_z, 0.0, 0.1)

func _on_animation_player_animation_finished(anim_name):
	queue_free()
	pass # Replace with function body.
