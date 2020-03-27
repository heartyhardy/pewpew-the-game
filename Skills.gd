extends Node2D

#THIS IS A GLOBAL MODULE

#SKILLS LIST
var skills = {
	"DODGE": 75
}

#SKILL STATUS
var skill_status = {
	"DODGE": true
}


#ENABLE A SKILL
func enable_skill(skill_id: String) -> void:
	if skill_status.has(skill_id):
		skill_status[skill_id] = true
	else:
		print_debug("SKILL ID NOT FOUND!")
		

#DISABLE A SKILL
func disable_skill(skill_id: String) -> void:
	if skill_status.has(skill_id):
		skill_status[skill_id] = false
	else:
		print_debug("SKILL ID NOT FOUND!")


#IS SKILL ENABLED
func is_skill_enabled(skill_id: String) -> bool:
	if skill_status.has(skill_id):
		if skill_status[skill_id]:
			return true
		else:
			return false
	return false


#SET SKILL VALUE
func set_skill(skill_id:String, value)->void:
	if skills.has(skill_id):
		skills[skill_id] = value
	else:
		print_debug("SKILL DOESNT EXIST!")
		

#GET SKILL VALUE
func get_skill(skill_id:String):
	if skills.has(skill_id):
		return skills[skill_id]
	else:
		return null
