extends Node2D

#AVAILABLE RANGE ATTACK AMMO TYPES
const REGULAR_ATTACK = preload("res://RegularBullet.tscn")

#UNLOCKED ATTACKS LIST
onready var UNLOCKED_ATTACKS = {
	1: true,
	2: false
}

onready var current_attack = 1


#GET CURRENTLY SELECTED AMMO TYPE
func get_current_attack():
	return get_ranged_attack(current_attack)
	
	
#SET CURRENT AMMO TYPE
func set_current_attack(ammo_type:int) -> bool:
	if is_attack_type_valid(ammo_type):
		current_attack = ammo_type
		return true
	else:
		return false
	

#IS GIVEN ATTACK VALID?
func is_attack_type_valid(ammo_type:int) -> bool:
	if UNLOCKED_ATTACKS.has(ammo_type):
		if UNLOCKED_ATTACKS[ammo_type]:
			return true
		else:
			return false
	return false
	

#GET RANAGED ATTACK AMMO TYPE BY KEY
func get_ranged_attack(ammo_type:int):
	if !is_attack_type_valid(ammo_type):
		return REGULAR_ATTACK
	match ammo_type:
		1: return REGULAR_ATTACK
		_: return REGULAR_ATTACK
