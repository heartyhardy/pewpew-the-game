extends Node2D

#AVAILABLE RANGE ATTACK AMMO TYPES
const DEFAULT_PUNCH = preload("res://MeleeDefaultPunch.tscn")

#UNLOCKED ATTACKS LIST
onready var UNLOCKED_ATTACKS = {
	1: true,
	2: false
}

onready var current_attack = 1


#GET CURRENTLY SELECTED AMMO TYPE
func get_current_attack():
	return get_melee_attack(current_attack)
	

#SET CURRENT MELEE ATTACK
func set_current_attack(punch_type:int) -> bool:
	if is_attack_type_valid(punch_type):
		current_attack = punch_type
		return true
	else:
		return false

	

#IS GIVEN ATTACK VALID?
func is_attack_type_valid(punch_type:int) -> bool:
	if UNLOCKED_ATTACKS.has(punch_type):
		if UNLOCKED_ATTACKS[punch_type]:
			return true
		else:
			return false
	return false
	

#GET MELEE ATTACK TYPE BY KEY
func get_melee_attack(punch_type:int):
	if !is_attack_type_valid(punch_type):
		return DEFAULT_PUNCH
	match punch_type:
		1: return DEFAULT_PUNCH
		_: return DEFAULT_PUNCH
