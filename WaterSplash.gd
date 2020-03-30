extends Node2D

func _ready():
	$Splash_Anim.frame = 0
	$Splash_Anim.play("Splash")

func _on_Splash_Anim_animation_finished():
	queue_free()
