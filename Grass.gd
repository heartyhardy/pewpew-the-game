extends Area2D

#GRASS TYPE
enum GRASS_TYPE {DEFAULT, PURPLE, YELLOW, RED, BLUE}
export(GRASS_TYPE) var grass_type

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

func _on_Grass_body_entered(body):
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
	$Grass_Anim.frame = 0


func _on_Grass_Anim_animation_finished():
	$Grass_Anim.stop()
