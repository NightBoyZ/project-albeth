#extends Node
#
#var entities = []
#var currentIndex = 0
#var enemy_per_frame = 0
#var total_spawned = 0
#
##Used to hold frame counts
#var frame_count = 0
#var frame_interval = 1
#
##current entity
#var entity_current: int
#
#@export var spawn_cap: int = 300
#@export var max_entities_spawned: int = 900
#@export var spawn_radius: int = 1
#@export var entity: Array = [preload("res://scenes/lesser_slime.tscn")]
#@onready var entity_counter = $UI/SpawnCounter
#
#func _ready():
	#print("Entity Manager Ready")
#
#func register_entity(entity):
	#entities.append(entity)
	#print("Registered entity:", entity.name)
#
#func update_entity_ai(delta):
	##enemy_per_frame = max(1, entities.size() / 10) 
	##print(enemy_per_frame)
	##for i in range(enemy_per_frame):
		##var index = currentIndex + i
		##if index < entities.size():
			##var selected_entity = entities[index]
			##selected_entity._update_ai(delta)
			##
	##currentIndex += enemy_per_frame		
	##if currentIndex >= entities.size():
		##currentIndex = 0
	#
	#for entity in entities:
		#entity._update_ai(delta)
		#
#func _physics_process(delta):
	#entity_counter.text = "Entity Count: " + str(entities.size())
	#if entities.size() < spawn_cap and total_spawned < max_entities_spawned:
		#var spawn = entity.pick_random().instantiate()
		#add_child(spawn)
		#var radius = randi_range(-spawn_radius, spawn_radius)
		#spawn.position = Vector3(radius, 2, radius)
		#register_entity(spawn)
	#
	#frame_count += 1
	#if frame_count % frame_interval == 0:
		#update_entity_ai(delta)
		
		
#co-modified by gpt-4
extends Node
class_name EntityManager

var objects = []
var capped_entities = []
var uncapped_entities = []
var current_entity_index = 0
var entities_per_frame = 0
#var max_entities_per_frame = 16   #Maximum entities to update per frame
var max_entities_per_frame: int  # Maximum entities to update per frame, dynamic because of load balancing
var target_fps = 60
var target_frame_time = 0.1 / target_fps
var total_spawned: int = 0
var total_killed: int = 0

var rng = RandomNumberGenerator.new()
var weighted_sum: int = 0
var time_holder: float

@export var enabled: bool = true
@export var survive_time: int = 60
@export var spawn_cap: int = 16
@export var max_entities_spawned: int = 80
@export var max_objects: int = 80
@export var to_next_spawn_cap: int = 5
@export var stat_scaling: float = 1
@export var stat_scaling_multiplier: float = 1.02
@export var spawn_scaling: float = 1.2
@export var max_kills: int = 0
@export var spawn_radius: int = 20

@export var entity_list: Array = [
	[preload("res://scenes/entities/slime/lesser_slime/lesser_slime.tscn"), true, 100],
	[preload("res://scenes/entities/slime/ice_slime/ice_slime.tscn"), true, 10],
	[preload("res://scenes/entities/slime/fire_slime/fire_slime.tscn"), true, 30],
	[preload("res://scenes/entities/slime/shock_slime/shock_slime.tscn"), true, 5],
	[preload("res://scenes/entities/slime/nature_slime/nature_slime.tscn"), true, 1],
	]
	
@onready var player_progressbar = %PlayerManager/Player/UI/GeneralUI/WaveBar
@onready var entity_counter = %PlayerManager/Player/UI/GeneralUI/DebugMenu/LevelDebug/SpawnCounter
@onready var kill_counter = %PlayerManager/Player/UI/GeneralUI/DebugMenu/LevelDebug/KillCounter
@onready var object_counter = %PlayerManager/Player/UI/GeneralUI/DebugMenu/LevelDebug/ObjectCounter
@onready var progress_counter = %PlayerManager/Player/UI/GeneralUI/DebugMenu/LevelDebug/ProgressCounter
@export var game_manager: Node3D

func _ready():
	#print("Entity Manager Ready")
	randomize()

func register_object(obj):
	objects.append(obj)
	#Object check
	if objects.size() >= max_objects:
		#If object is more than max_objects, queue_free the oldest element
		objects[-1].remove_goo()
	#print("Registered object:", obj.name)
	
func register_capped_entity(entity):
	capped_entities.append(entity)
	#print("Registered entity:", entity.name)

func register_uncapped_entity(entity):
	uncapped_entities.append(entity)
	#print("Registered entity:", entity.name)

func erase_object(obj):
	objects.erase(obj)
	#print("Erased object:", obj.name)
	obj.queue_free()
	
func erase_capped_entity(entity):
	capped_entities.erase(entity)
	#print("Erased entity:", entity.name)
	entity.queue_free()

func erase_uncapped_entity(entity):
	uncapped_entities.erase(entity)
	#print("Erased entity:", entity.name)
	entity.queue_free()
	
#Handles spawning and capping
func _process(delta):
	player_progressbar.set("value", time_holder)
	player_progressbar.set("max_value", survive_time)
	entity_counter.set("text", "Entity Count: " + str(capped_entities.size()))
	object_counter.set("text", "Object Counter: " + str(objects.size()))
	kill_counter.set("text", "Kill Counter: " + str(total_killed))
	progress_counter.set("text", "Progress to next Spawn Cap: " + str(to_next_spawn_cap - total_killed))
	
	#Triggers a level complete popup when a specific time is reached
	if enabled:
		if (int(time_holder) % 60) > survive_time:
			level_complete()
			
		#Triggers a level complete popup when a max kill is set
		if max_kills > 0:
			if total_killed >= max_kills:
				level_complete()
				
		if total_killed >= to_next_spawn_cap:
			stat_scaling *= stat_scaling_multiplier
			print(stat_scaling)
			increase_spawn_cap()
		
func _physics_process(delta):
	if enabled:	
		update_entity_ai(delta)
		update_uncapped_ai(delta)
		
		#Entity check
		if capped_entities.size() < spawn_cap and capped_entities.size() < max_entities_spawned:
			spawn_entity()
				
func spawn_entity():
	#var radius = randi_range(-spawn_radius, spawn_radius)
	rng.randomize()
	#Spawns random enemies
	var pick_entity = entity_list.pick_random()
	if pick_entity[1] == true:
		var spawn = pick_entity[0].instantiate()
		spawn.position = Vector3(randi_range(-spawn_radius, spawn_radius), 3, randi_range(-spawn_radius, spawn_radius))
		add_child(spawn)
		total_spawned += 1
	return
		
func increase_spawn_cap():
	spawn_cap *= spawn_scaling
	to_next_spawn_cap += (to_next_spawn_cap * spawn_scaling)
	return
		
func level_complete():
	for i in capped_entities:
		i.dead()
		
	for i in uncapped_entities:
		i.dead()
		
	#adjust to show level complete screen
	if enabled and capped_entities.size() <= 0:
		game_manager.game_complete = true
		enabled = false
		
	return

func level_lost():
	if enabled:
		enabled = false
	return
	
func update_uncapped_ai(delta):
	for i in uncapped_entities:
		i._update_ai(delta)

#Dynamic AI process balancing (gpt-4)
func update_entity_ai(delta):
	var start_time = Time.get_ticks_usec()
	var updates_done = 0
	
	#Dynamic load balancing (gpt-4)
	#Dynamically adjusts maximum entities to update, 
	#if frame update time takes longer than the target (Target fps/0.1)
	#enemy updates will be more lenient, otherwise more entities will get updated
	var end_time = Time.get_ticks_usec()
	var frame_time = (end_time - start_time) / 1000000.0
	if frame_time > target_frame_time:
		max_entities_per_frame = max(1, max_entities_per_frame - 1)
	else:
		max_entities_per_frame += 1

	#to be temporarily comment to test updated slime logic
	#updates done to check for batches depending on max entity updates per frame
	while updates_done < max_entities_per_frame:
		var index = current_entity_index + updates_done
		if index < capped_entities.size():
			var selected_entity = capped_entities[index]
			selected_entity._update_ai(delta)
			updates_done += 1
		else:
			break
	
	current_entity_index += updates_done
	if current_entity_index >= capped_entities.size():
		current_entity_index = 0
