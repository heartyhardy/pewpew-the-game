extends Area2D

export(int) var speed = 50
export(int) var damage = 100

var velocity = Vector2()
var direction = 1

func _ready():
	pass


#SET SHELL DIRECTION
func set_direction(dir):
	direction = dir
	if direction == -1:
		$Shell_Anim.flip_h = false
	else:
		$Shell_Anim.flip_h = true


func _physics_process(delta):
	velocity.x = speed * direction * delta
	translate(velocity)
	$Shell_Anim.play("ShellFired")


#ON HIT
func _on_ObserverShell_body_entered(body):
	if body.name == "Player":		
		#IF PLAYER IS DEAD RETURN
		if !body.is_alive:
			return
			
		if Skills.is_skill_enabled("DODGE"):
			var dodge_perc = Skills.get_skill("DODGE")
			var is_dodged = SkillChecks.can_dodge(dodge_perc)
			if !is_dodged:
				body.on_enemy_hit(damage)
			else:
				body.on_enemy_hit(0, true)
				return
		else:
			body.on_enemy_hit(damage)
	queue_free()


#ON EXIT SCREEN
func _on_Shell_Visibility_screen_exited():
	queue_free()


