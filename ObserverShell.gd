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


func _on_Shell_Visibility_screen_exited():
	queue_free()
