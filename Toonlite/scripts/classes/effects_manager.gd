extends Node3D #Node3d because need to follow character
class_name EffectsManager

func new_effect(effect_name):
	add_child(effect_name)
