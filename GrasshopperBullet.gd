extends Area2D

export(int) var speed = 75
export(int) var damage = 25

var velocity = Vector2()
var direction = 1

func _ready():
	pass


#SET BULLET FACING DIRECTION
func set_direction(dir):
	direction = dir
	if direction == -1:
		$Bullet_Anim.flip_h = false
	else:
		$Bullet_Anim.flip_h = true


func _physics_process(delta):
	velocity.x = speed * direction * delta
	translate(velocity)
	$Bullet_Anim.play("BulletFired")	


#ON HIT
func _on_GrasshopperBullet_body_entered(body):
	if body.name == "Player":
#		IF DEAD DONT QUEUE FREE ON BODY COLLISION
		if !body.is_alive:
			return
			
		if Skills.is_skill_enabled("DODGE"):
			var dodge_perc = Skills.get_skill("DODGE")
			var is_dodged = SkillChecks.can_dodge(dodge_perc)
			if !is_dodged:
				body.on_enemy_hit(damage)
			else:
				body.on_enemy_hit(0, true, direction)
				return
		else:
			body.on_enemy_hit(damage)
	queue_free()


#ON EXIT SCREEN
func _on_BulletVisibility_screen_exited():
	queue_free()
