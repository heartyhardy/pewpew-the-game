extends KinematicBody2D

export(int) var speed = 30
export(int) var hp = 100
export(int) var armor = 50
export(int) var ammo = 100

const GRAVITY = 10
const JUMP_FORCE = -250
const FLOOR = Vector2(0, -1)

const REGULAR_BULLET = preload("res://RegularBullet.tscn")

var velocity = Vector2()
var is_on_ground = false
var is_attacking = false
var is_alive = true

func _ready():
	PlayerGlobals.set("player", self)
	PlayerGlobals.set("hp", hp)
	PlayerGlobals.set("armor", armor)
	PlayerGlobals.set("ammo", ammo)

func _physics_process(delta):
	
#	IF DEAD DON'T PROCESS PHYSICS
	if !is_alive and is_on_floor():
		return
	
#	HORIZONTAL MOVEMENT
	if Input.is_action_pressed("ui_right") and is_alive:
		if !is_attacking or !is_on_floor():
			velocity.x = speed
			if !is_attacking:
				$Player_Anim.play("Run")
				$Player_Anim.flip_h = false
				if sign($ShootPoint.position.x)  == -1:
					$ShootPoint.position.x *= -1
	elif Input.is_action_pressed("ui_left") and is_alive:
		if !is_attacking or !is_on_floor():
			velocity.x = -speed
			if !is_attacking:
				$Player_Anim.play("Run")
				$Player_Anim.flip_h = true
				if sign($ShootPoint.position.x) == 1:
					$ShootPoint.position.x *= -1
	else:
		velocity.x = 0
		if is_on_ground and !is_attacking and is_alive:
			$Player_Anim.play("Idle")
	
#	VERTICAL MOVEMENT
	if Input.is_action_pressed("ui_up") and is_on_ground and is_alive:
		if !is_attacking:
			velocity.y = JUMP_FORCE
			is_on_ground = false
		
#	SHOOT IF PLAYER HAS AMMO
	if Input.is_action_just_pressed("ui_select") and !is_attacking and is_alive:
		if ammo <= 0:
			return
		if is_on_floor():
			velocity.x = 0
		is_attacking = true
		reduce_one_from_ammo()
		$Player_Anim.play("Shoot")
		var weapon_projectile = REGULAR_BULLET.instance()
		weapon_projectile.set_direction(sign($ShootPoint.position.x))
		get_parent().add_child(weapon_projectile)
		weapon_projectile.position = $ShootPoint.global_position
	
#	PROCESSING GRAVITY
	velocity.y += GRAVITY
	
#	IS PLAYER ON FLOOR?
	if is_on_floor() and is_alive:
		if !is_on_ground:
			is_attacking = false
		is_on_ground = true
	else:
		if !is_attacking and is_alive:
			is_on_ground = false
			if velocity.y < 0:
				$Player_Anim.play("Jump")
			else:
				$Player_Anim.play("Fall")
		
	velocity = move_and_slide(velocity, FLOOR)
	

#ON TAKE DAMAGE SEE IF PLAYER IS ALIVE AND UPDATE HP
func on_enemy_hit(dmg):
	if !$PulseTween.is_active():
		$PulseTween.interpolate_property(self,"modulate", Color.white, Color.red, 0.5, Tween.TRANS_SINE,Tween.EASE_OUT)
		$PulseTween.start()
		$PulseStopTimer.start()
	reduce_from_armor(dmg)
	PlayerGlobals.set_hp(hp)
	if hp <= 0:
		PlayerGlobals.set_hp(hp)
		on_player_death()
		

#ON SHOOT REDUCE ONE AMMO FROM CURRENT AMMO
func reduce_one_from_ammo():
	ammo -= 1
	if ammo < 0:
		ammo = 0
	PlayerGlobals.set_ammo(ammo)

#IF PLAYER HAS ARMOR REDUCE DMG FROM ARMOR, IF NOT REDUCE FROM HP
func reduce_from_armor(dmg):
	var remainder = armor - dmg
	if remainder >= 0:
		armor = remainder
	elif remainder < 0:
		hp += remainder
		armor = 0
	PlayerGlobals.set_armor(armor)
		
		
#WHEN PLAYER DIES DO THESE
func on_player_death():
	$PulseTween.stop(self)
	$PulseStopTimer.stop()
	self.modulate = Color.white
	is_alive = false
	$Player_Anim.play("Death")
	

#IS THE ANIMATION DONE?
func _on_Player_Anim_animation_finished():
	if !is_alive:
		queue_free()
	is_attacking = false


func _on_PulseStopTimer_timeout():
	$PulseTween.set_active(false)
	self.modulate = Color.white
	$PulseStopTimer.stop()
