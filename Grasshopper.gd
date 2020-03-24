extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)
const BULLET = preload("res://GrasshopperBullet.tscn")

export(int) var speed = 45
export(int) var hp = 25
export(int) var shoot_speed = 75
export(int) var damage = 25

var velocity = Vector2()
var direction = 1
var is_attacking = false
var is_alive = true

onready var hpbar = $HealthBar

func _ready():
	self.set_meta("TAG","ENEMY")
	hpbar.on_maxhp_updated(hp)
	hpbar.on_hp_updated(hp)

func _physics_process(delta):
	
#	IF DEAD RETURN
	if !is_alive:
		return
	
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
	else:
		is_attacking = false
		
#	IF LEDGE DETECTED, TURN
	if !$LedgeDetectRay.is_colliding() and !is_attacking:
		turn()


#TURN IF HITS A WALL OR LEDGE
func turn():
	direction *= -1
	$LedgeDetectRay.position.x *= -1
	$VisionRay.position.x *= -1
	$VisionRay.cast_to *= -1
	$ShootPoint.position.x *= -1


#FIRE BULLET
func fire():
	var weapon_projectile = BULLET.instance()
	weapon_projectile.speed = shoot_speed
	weapon_projectile.damage = damage
	weapon_projectile.set_direction(sign($ShootPoint.position.x))
	get_parent().add_child(weapon_projectile)
	weapon_projectile.position = $ShootPoint.global_position


#ON TAKE DAMAGE BY PLAYER
func hit_by_player(dmg):
	hp -= dmg
	hpbar.on_hp_updated(hp)
	if hp <= 0:
		is_alive = false
		$Grasshopper_Hitbox.set_deferred("disabled", true)
		$Grasshopper_Anim.play("Death")
	

#SYNC FIRE ANIMATION
func _on_Grasshopper_Anim_frame_changed():
	if $Grasshopper_Anim.animation == "Attack":
		if $Grasshopper_Anim.frame == 1:
			fire()


func _on_Grasshopper_Anim_animation_finished():
	if !is_alive:
		queue_free()
