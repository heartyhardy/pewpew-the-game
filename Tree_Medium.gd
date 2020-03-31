extends Area2D

export(int) var heal_amount = 1
export(int) var max_heal = 25
export(bool) var infinite_heal = false

func _ready():
	$Tree_Heal_Anim.visible = false
	$Tree_Heal_Anim.stop()


func activate_healing(body):
	if infinite_heal or max_heal > 0:
		if body.name == "Player":
			print_debug("Healing...")
			body.is_tree_heal_active = true
			if !$Tree_Heal_Anim.playing:
				$Tree_Heal_Anim.visible = true
				$Tree_Heal_Anim.play("Heal")	
			$Tree_Heal_Timer.start()
	

func deactivate_healing(body):
	if body.name == "Player":
		print_debug("Left tree...")		
		body.is_tree_heal_active = false
		$Tree_Heal_Timer.stop()
		

func _on_Tree_Medium_body_entered(body):
	activate_healing(body)


func _on_Tree_Heal_Timer_timeout():
	if !infinite_heal and max_heal <= 0:
		$Tree_Heal_Timer.stop()
		return
		
	if !$Tree_Heal_Anim.playing:
		$Tree_Heal_Anim.visible = true
		$Tree_Heal_Anim.play("Heal")
	max_heal -= heal_amount 
	PlayerGlobals.get_player().on_regen(heal_amount)


func _on_Tree_Medium_body_exited(body):
	deactivate_healing(body)


func _on_Tree_Heal_Anim_animation_finished():
	$Tree_Heal_Anim.stop()
	$Tree_Heal_Anim.frame = 0
	$Tree_Heal_Anim.visible = false
