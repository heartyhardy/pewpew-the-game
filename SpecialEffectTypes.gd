extends Node2D

#AVAILABLE RANGE ATTACK AMMO TYPES
const WATER_SPLASH = preload("res://WaterSplash.tscn")
const BREAKABLE_TILE = preload("res://BreakableTile.tscn")

enum EFFECT {
	WATER_SPLASH = 1,
	BREAKABLE_TILE = 2
}

#GET RANAGED ATTACK AMMO TYPE BY KEY
func get_special_effect(effet_type:int):
	match effet_type:
		EFFECT.WATER_SPLASH: return WATER_SPLASH
		EFFECT.BREAKABLE_TILE: return BREAKABLE_TILE
		_: return null
