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
		$Shell_Anim.flip_h = true
	else:
		$Shell_Anim.flip_h = false


func _physics_process(delta):
	velocity.x = speed * direction * delta
	translate(velocity)
	$Shell_Anim.play("ShellFired")


#ON HIT
func _on_ObserverShell_body_entered(body):
	if body.name == "Player":
		body.on_enemy_hit(damage)
	queue_free()


#ON EXIT SCREEN
func _on_Shell_Visibility_screen_exited():
	queue_free()


