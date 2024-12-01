extends BoneAttachment3D

@onready var hitbox: Area3D = $ScalingFix/Model/WeaponHitbox
@onready var trail: GPUTrail3D = $ScalingFix/GPUTrail3D

@export var weapon_power = 12
@export var knockback_power = 3
@export var equipper: CharacterBody3D
var players: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	update_hitbox(false)
	players = get_tree().get_first_node_in_group("players")	
	
func update_hitbox(update: bool):
	hitbox.monitoring = update
	hitbox.monitorable = update
	trail.visible = update
	
func _on_weapon_hitbox_area_entered(area):
	var body = area.get_parent()
	if body.is_in_group("enemies") and equipper.can_act:
		body.take_damage(randi_range(weapon_power/2 + equipper.strength, weapon_power*2 + equipper.strength))
		body.take_knockback(knockback_power, players.global_position)
