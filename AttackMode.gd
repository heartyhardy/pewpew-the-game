extends Node2D

enum ATTACK_MODES {MELEE = 1, RANGED = 2}

var attack_mode_length = 2
var current_attack_mode = ATTACK_MODES.MELEE


#SET CURRENT ATTACK MODE
#attack modes are "MELEE" =  0, "GUN" = 1
func set_attack_mode(mode: int):
	current_attack_mode = mode


#GET CURRENT ATTACK MODE
func get_attack_mode() -> int:
	return current_attack_mode
	

#TOGGLE ATTACK MODE
func cycle_attack_mode() -> int:
	current_attack_mode += 1
	if current_attack_mode > attack_mode_length:
		current_attack_mode = ATTACK_MODES.MELEE
	return current_attack_mode
