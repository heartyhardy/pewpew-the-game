extends Node2D

#AVAILABLE RANGE ATTACK AMMO TYPES
const WATER_SPLASH = preload("res://WaterSplash.tscn")


#GET RANAGED ATTACK AMMO TYPE BY KEY
func get_special_effect(effet_type:int):
	match effet_type:
		1: return WATER_SPLASH
		_: return null
