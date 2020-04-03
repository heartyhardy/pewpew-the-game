extends Node2D

var animations = {
	"IDLE": ["MeleeIdle", "Idle"],
	"RUN": ["MeleeRun", "Run"],
	"JUMP": ["MeleeJump", "Jump"],
	"DODGE": ["MeleeDodge", "Dodge"],
	"DEATH": ["MeleeDeath", "Death"],
	"DUCK": ["MeleeDuck", "Duck"],
	"FALL": ["MeleeFall", "Fall"],
	"ATTACK": ["MeleeAttack", "Shoot"]
	}


#GET ANIMATION BY KEY
func  get_animation(key: String, attack_mode:int = 0) -> String:
	if animations.has(key):
		return animations[key][attack_mode-1]
	else:
		return ""
