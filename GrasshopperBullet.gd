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
		body.on_enemy_hit(damage)
	queue_free()


#ON EXIT SCREEN
func _on_BulletVisibility_screen_exited():
	queue_free()
