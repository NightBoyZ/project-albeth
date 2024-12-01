extends MeshInstance3D

@export var speed_modifier: float = 1.05
@export var puddle_size: float = 2
@export var dry_time: float = 3
@onready var detection_zone: CollisionShape3D = $Area3D/CollisionShape3D

var player: CharacterBody3D
var move_dir: Vector3
var entity_manager = null

#Called when state firstly transitioned
func _ready() -> void:
	entity_manager = get_tree().root.get_node("GameManager/EntityManager")
	entity_manager.register_object(self)
	
	mesh.size *= puddle_size
	detection_zone.shape.radius *= puddle_size
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(1,1,1), 0.2)
	
func _process(delta: float) -> void:
	dry_time -= delta
		
	if dry_time < 0:
		var tween = get_tree().create_tween()
		tween.tween_property(mesh.material, "albedo_color", Color8(255,255,255,0), 1)
		
		await tween.finished
		entity_manager = get_tree().root.get_node("GameManager/EntityManager")
		entity_manager.erase_object(self)
