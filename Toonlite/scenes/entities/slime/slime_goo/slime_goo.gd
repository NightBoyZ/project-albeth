extends Area3D

@export var speed_modifier: float = 1.05
@export var puddle_size: float = 1
@export var dry_time: float = 20
@onready var goo_texture: MeshInstance3D = $GooTexture
@onready var detection_zone: CollisionShape3D = $CollisionShape3D

var player: CharacterBody3D
var move_dir: Vector3
var entity_manager = null

var color: Color
var glow: Color
var is_sticky: bool = false
var is_slippery: bool = false
var is_burning: bool = false
var is_conductive: bool = false

#Called when state firstly transitioned
func _ready() -> void:
	entity_manager = get_tree().root.get_node("GameManager/EntityManager")
	entity_manager.register_object(self)
	
	goo_texture.mesh.size *= puddle_size
	goo_texture.mesh.material.albedo_color = color
	goo_texture.mesh.material.emission = glow
	detection_zone.shape.radius *= puddle_size
	return
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "scale", Vector3(1,1,1), 0.2)
	
func _process(delta: float) -> void:
	dry_time -= delta
	if dry_time < 0:
		remove_goo()
	return
		
func remove_goo():
	var tween = get_tree().create_tween()
	tween.tween_property(goo_texture.mesh.material, "albedo_color", Color8(255,255,255,0), 1)
	await tween.finished
	
	entity_manager = get_tree().root.get_node("GameManager/EntityManager")
	entity_manager.erase_object(self)
	return
