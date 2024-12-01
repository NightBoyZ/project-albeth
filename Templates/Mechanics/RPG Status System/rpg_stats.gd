extends Control

#Move health and stamina to entity script, call with signals.
@export var maxhealth: int = 20
@export var health: int = 20

@export var maxstamina: int = 20
@export var stamina: int = 20

@onready var HealthBar: ProgressBar = $HPBar
@onready var EnergyBar: ProgressBar = $STBar

func _ready():
	HealthBar.max_value = maxhealth
	EnergyBar.max_value = maxstamina
	pass 

func _process(delta): 
	health -= 1; stamina -= 1
	
	HealthBar.value = health
	EnergyBar.value = stamina
	
	if health < 0:
		health = maxhealth
		stamina = maxstamina
