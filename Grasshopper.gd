extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)

export(int) var speed = 45
export(int) var hp = 25
export(int) var damage = 25

var velocity = Vector2()
var direction = 1
var is_attacking = false
var is_alive = true


func _ready():
	self.set_meta("TAG","ENEMY")
	

func _physics_process(delta):
#	ONLY MOVE IF NOT ATTACKING
	if !is_attacking:
		velocity.x = speed * direction
	
#	APPLY GRAVITY	
	velocity.y += GRAVITY
	
#	FLIP DIRECTION
	if direction == -1:
		$Grasshopper_Anim.flip_h = false
	else:
		$Grasshopper_Anim.flip_h = true
		
#	CHANGE ANIMATION DEPENDING ON STATE
	if !is_attacking:
		$Grasshopper_Anim.play("Patrol")
	elif is_attacking:
		$Grasshopper_Anim.play("Attack")
	
	if !is_attacking:
		velocity = move_and_slide(velocity, FLOOR)
	
#	IF HITS A WALL, TURN
	if is_on_wall():
		turn()
		
#	IF PLAYER DETECTED, ATTACK
	if $VisionRay.is_colliding():
		if $VisionRay.get_collider().name == "Player":
			is_attacking = true
	else:
		is_attacking = false
		
#	IF LEDGE DETECTED, TURN
	if !$LedgeDetectRay.is_colliding() and !is_attacking:
		turn()

func turn():
	direction *= -1
	$LedgeDetectRay.position.x *= -1
	$VisionRay.position.x *= -1
	$VisionRay.cast_to *= -1
