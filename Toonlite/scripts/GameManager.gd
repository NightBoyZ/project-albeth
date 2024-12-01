extends Node3D
class_name GameManager

var time_holder: float
var paused: bool = false
var game_complete: bool = false
var game_failed: bool = false
var pause_menu_toggled: bool = false

@onready var entities = get_tree().get_nodes_in_group("enemies")
@onready var pause_menu = %PauseMenu
@onready var players = %PlayerManager/Player
@onready var entity_manager = %EntityManager
@onready var time_played = %PlayerManager/Player/UI/GeneralUI/WaveBar/Playtime
@onready var fps_counter = %PlayerManager/Player/UI/GeneralUI/DebugMenu/LevelDebug/FPS
@onready var level_ui_toggler = %PlayerManager/Player/UI/LevelProgress

@export var save_file: JSON #Unused

# Called when the node enters the scene tree for the first time.
func _ready():
	paused = false
	game_complete = false
	game_failed = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	time_holder += delta
	entity_manager.time_holder += delta
	time_played.text = "%d:%02d" % [floori(time_holder / 60), int(time_holder) % 60]
	fps_counter.text = "FPS " + str(Engine.get_frames_per_second())
	
	if Input.is_action_just_pressed("esc") and (!game_complete or !game_failed):
		toggle()
	
	if !paused:
		if game_complete:
			paused = true
			players.can_act = false
			players.camera_rotate = false
			level_ui_toggler.play("GameComplete")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
			await level_ui_toggler.animation_finished
			var time_stop = get_tree().create_tween()
			time_stop.tween_property(Engine, "time_scale", 0.2, 0.2)
			
		if game_failed:
			paused = true
			players.can_act = false
			players.camera_rotate = false
			level_ui_toggler.play("GameFailed")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
			await level_ui_toggler.animation_finished
			var time_stop = get_tree().create_tween()
			time_stop.tween_property(Engine, "time_scale", 0.2, 0.2)
			
			
func toggle():
	pause_menu_toggled = !pause_menu_toggled
	pause_menu.visible = pause_menu_toggled
	
	entity_manager.enabled = !entity_manager.enabled
	players.can_act = !players.can_act
	players.camera_rotate = !players.camera_rotate
	players.UI.visible = !players.UI.visible
	
	if pause_menu_toggled == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  
		#players.can_act = false
		players.animation_tree.set("parameters/Pause/scale", 0)
		# To pause physics
		Engine.time_scale = 0.0
	elif pause_menu_toggled == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#players.can_act = false
		players.animation_tree.set("parameters/Pause/scale", 1)
		# To resume physics
		Engine.time_scale = 1.0
