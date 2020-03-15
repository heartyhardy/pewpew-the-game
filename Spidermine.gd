extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)

export(int) var speed = 40
var velocity = Vector2()
var direction = 1
var is_attacking = false

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	velocity.x = speed * direction
	velocity.y += GRAVITY
	
#	FLIP SPRITE WHEN DIRECTION CHANGES
	if direction == -1:
		$Spider_Anim.flip_h = true
	else:
		$Spider_Anim.flip_h = false
	
#	CHANGE ANIMATION DEPENDING ON STATE
	if !is_attacking:
		$Spider_Anim.play("Patrol")
	elif is_attacking:
		$Spider_Anim.play("Attack")
		
		
	velocity = move_and_slide(velocity, FLOOR)
	
#	CHANGE RAYCASTING DIRECTION
	if is_on_wall():
		direction *= -1
		$LedgeDetectRay.position.x *= -1
		$VisonRay.position.x *= -1
		$VisonRay.cast_to *= -1
	
#	IF PLAYER IS BEING DETECTED ATTACK
	if $VisonRay.is_colliding():
		if $VisonRay.get_collider().name == "Player":
			is_attacking = true
	else:
		is_attacking = false

#	IF LEDGE IS DETECTED CHANGE RAYCASTING DIRECTION
	if !$LedgeDetectRay.is_colliding() and !is_attacking:
		direction *= -1
		$LedgeDetectRay.position.x *= -1
		$VisonRay.position.x *= -1
		$VisonRay.cast_to *= -1
		
