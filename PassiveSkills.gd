extends Node2D

const PASSIVE_SKILLS = {
#	ADDS 20 TO SPEED
	"MINOR_HASTE": [false, 10]
	}
	

#IS SKILL ACTIVE
func is_skill_active(skill: String) -> bool:
	if PASSIVE_SKILLS.has(skill):
		return PASSIVE_SKILLS[skill][0]
	return false
	
	
#ACTIVATE A SKILL
func activate_skill(skill: String) -> int:
	if PASSIVE_SKILLS.has(skill):
		PASSIVE_SKILLS[skill][0] = true
		return PASSIVE_SKILLS[skill][1]
	return -1


#DEACTIVATE A SKILL
func deactivate_skill(skill: String) -> int:
	if PASSIVE_SKILLS.has(skill):
		PASSIVE_SKILLS[skill][0] = false
		return PASSIVE_SKILLS[skill][1]
	return -1


func _physics_process(delta):
#	APPLY MINOR HASTE IF IN MELEE MODE
	print_debug(PlayerGlobals.get("is_on_ground"))
	toggle_minor_haste()


#PASSIVE SKILLS SECTION

#*** MINOR HASTE ***

#APPLY MINOR HASTE WHEN IN MELEE MODE
func apply_minor_haste():
	if is_skill_active("MINOR_HASTE"):
		var current_speed = PlayerGlobals.get_speed()
		PlayerGlobals.set_speed(current_speed + PASSIVE_SKILLS["MINOR_HASTE"][1])

#REMOVE MINOR HASTE WHEN NOT IN MELEE MODEc		
func remove_minor_haste():
	if !is_skill_active("MINOR_HASTE"):
		var current_speed = PlayerGlobals.get_speed()
		PlayerGlobals.set_speed(current_speed - PASSIVE_SKILLS["MINOR_HASTE"][1])
	

#TOGGLE MINOR HASTE
func toggle_minor_haste():
	if AttackMode.get_attack_mode() == AttackMode.ATTACK_MODES.MELEE and PlayerGlobals.get("is_on_ground"):
		if !is_skill_active("MINOR_HASTE"):
			activate_skill("MINOR_HASTE")
			apply_minor_haste()
	elif AttackMode.get_attack_mode() != AttackMode.ATTACK_MODES.MELEE or !PlayerGlobals.get("is_on_ground"):
		if is_skill_active("MINOR_HASTE"):
			deactivate_skill("MINOR_HASTE")
			remove_minor_haste()
