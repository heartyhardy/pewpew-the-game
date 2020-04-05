extends Area2D

export(int) var damage = 25
export(float) var cooldown = 0.35

const SPEED = 50

var distance = 0
var velocity = Vector2()
var direction = 1


func _ready():
	$Punch_Anim.play("Punch")
	

#SET PROJECTILE DIRECTION
func set_direction(dir:int):
	direction = dir
	if direction == 1:
		$Punch_Anim.flip_h = false
	elif direction == -1:
		$Punch_Anim.flip_h = true
		

func _physics_process(delta):
	distance += SPEED
	velocity.x = SPEED * delta * direction
	translate(velocity)
	
	if distance > 150:
		queue_free()
	

func _on_MeleeDefaultPunch_body_entered(body):
	if body.name != 'TileMap':
		var b_type = body.get_meta("TAG")
		if b_type == "ENEMY":
			body.hit_by_player(damage)
#	queue_free()
