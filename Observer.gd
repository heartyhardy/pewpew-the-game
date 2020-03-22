extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)
const SHELL = preload("res://ObserverShell.tscn")

export(int) var speed = 40

var velocity = Vector2()
var direction = 1
var is_attacking = false

func _ready():
	set_meta("TAG", "ENEMY")


func _physics_process(delta):
#	MOVE NORMALLY IF NOT ATTACKING
	if !is_attacking:
		velocity.x = speed * direction
		
#	APPLY GRAVITY	
	velocity.y += GRAVITY
	
#	TURN DEPENDING ON DIRECTION
	if direction == -1:
		$Observer_Ani.flip_h = true
		$ObserverFireEffect/FireEffect.flip_h = true
	elif direction == 1:
		$Observer_Ani.flip_h = false
		$ObserverFireEffect/FireEffect.flip_h = false
		

#	CHANGE ANIMATION DEPENDING ON STATE
	if !is_attacking:
		$ObserverFireEffect.visible = false
		$ObserverFireEffect/FireEffect.stop()
		$Observer_Ani.play("Roll")
	elif is_attacking:
		$Observer_Ani.play("Attack")	
	
	if !is_attacking:
		velocity = move_and_slide(velocity, FLOOR)
	
#	IF HITS A WALL, TURN
	if is_on_wall():
		turn()
		
#	IF PLAYER DETECTED GO ATTACK MODE
	if $VisionRay.is_colliding():
		if $VisionRay.get_collider().name == "Player":
			if !$AggressionCooldown.is_stopped():
				$AggressionCooldown.stop()
			is_attacking = true
	else:
		if $AggressionCooldown.is_stopped():
			$AggressionCooldown.start()
						
	
#	IF LEDGE DETECTED, TURN	
	if !$LedgeDetectRay.is_colliding() and !is_attacking:
		turn()

#TURN THE DIRECTION, RAY CASTER POSITIONS	
func turn():
	direction *= -1
	$LedgeDetectRay.position.x *= -1
	$VisionRay.position.x *= -1
	$VisionRay.cast_to *= -1
	$ObserverFireEffect.position.x *= -1
	$ShootPoint.position.x *= -1


func fire():
	var weapon_projectile = SHELL.instance()
	weapon_projectile.set_direction(sign($ShootPoint.position.x))
	get_parent().add_child(weapon_projectile)
	weapon_projectile.position = $ShootPoint.global_position

#ON TIMEOUT STOP PLAYER AGGRESSION
func _on_AggressionCooldown_timeout():
	is_attacking = false


func _on_Observer_Ani_frame_changed():
	if $Observer_Ani.animation == "Attack":
		if $Observer_Ani.frame == 3:
			if !$ObserverFireEffect/FireEffect.is_playing():
				$ObserverFireEffect.visible = true
				$ObserverFireEffect/FireEffect.visible = true
				$ObserverFireEffect/FireEffect.play("Fire")
				fire()
		elif $Observer_Ani.frame == 1:
			$ObserverFireEffect/FireEffect.stop()
			
