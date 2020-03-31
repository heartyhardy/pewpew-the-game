extends Area2D

#GRASS TYPE
enum GRASS_TYPE {DEFAULT, PURPLE, YELLOW, RED, BLUE}
export(GRASS_TYPE) var grass_type
export(int) var dodge_bonus = 10

var is_dodge_bonus_active = false

func _ready():
	if !$Grass_Anim.is_playing():
		match grass_type:
			GRASS_TYPE.DEFAULT:
				$Grass_Anim.play("Idle")
			GRASS_TYPE.PURPLE:
				$Grass_Anim.play("IdlePurple")
			GRASS_TYPE.YELLOW:
				$Grass_Anim.play("IdleYellow")
			GRASS_TYPE.RED:
				$Grass_Anim.play("IdleRed")
			GRASS_TYPE.BLUE:
				$Grass_Anim.play("IdleBlue")


#APPLY DODGE BONUS IF ON GRASS AND IF PLAYER
func activate_dodge_bonus(body):
	if body.name == "Player":
		var dodge = Skills.get_skill("DODGE")
		if Skills.is_skill_enabled("DODGE") and !is_dodge_bonus_active:
			body.is_grass_dodge_active = true			
			Skills.set_skill("DODGE", dodge + dodge_bonus)
			

#DEACTIVATE DODGE BONUS IF ALREADY APPLIED
func deactivate_dodge_bonus(body):
	if body.name == "Player":
		var dodge = Skills.get_skill("DODGE")
		if body.is_grass_dodge_active:
			body.is_grass_dodge_active = false
			Skills.set_skill("DODGE", dodge - dodge_bonus)
						

func _on_Grass_body_entered(body):
#	IF DODGE ENABLED, BOOST DODGE PERC by DODGE BONUS
	activate_dodge_bonus(body)
				
	$Grass_Anim.frame = 0
	match grass_type:
		GRASS_TYPE.DEFAULT:
			$Grass_Anim.play("Wave")
		GRASS_TYPE.PURPLE:
			$Grass_Anim.play("WavePurple")
		GRASS_TYPE.YELLOW:
			$Grass_Anim.play("WaveYellow")
		GRASS_TYPE.RED:
			$Grass_Anim.play("WaveRed")
		GRASS_TYPE.BLUE:
			$Grass_Anim.play("WaveBlue")


func _on_Grass_body_exited(body):
	deactivate_dodge_bonus(body)
	$Grass_Anim.frame = 0


func _on_Grass_Anim_animation_finished():
	$Grass_Anim.stop()
