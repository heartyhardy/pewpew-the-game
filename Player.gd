extends KinematicBody2D

export(int) var speed = 30
export(int) var hp = 100
export(int) var armor = 50
export(int) var ammo = 100

export(int) var cam_right_limit
export(int) var cam_top_limit
export(int) var cam_bottom_limit

const GRAVITY = 10
const JUMP_FORCE = -250
const FLOOR = Vector2(0, -1)

const REGULAR_BULLET = preload("res://RegularBullet.tscn")

var velocity = Vector2()
var is_on_ground = false
var is_attacking = false
var is_ducked = false
var is_alive = true

func _ready():
	PlayerGlobals.set("player", self)
	PlayerGlobals.set("hp", hp)
	PlayerGlobals.set("armor", armor)
	PlayerGlobals.set("ammo", ammo)
	
	$Player_Cam.limit_right = cam_right_limit
	$Player_Cam.limit_top = cam_top_limit
	$Player_Cam.limit_bottom = cam_bottom_limit

func _physics_process(delta):
	
#	IF DEAD DON'T PROCESS PHYSICS
	if !is_alive and is_on_floor():
		return
	
#	HORIZONTAL MOVEMENT
	if Input.is_action_pressed("ui_right") and !is_ducked and is_alive:
		if !is_attacking or !is_on_floor():
			velocity.x = speed
			if !is_attacking:
				$Player_Anim.play("Run")
				$Player_Anim.flip_h = false
				if sign($ShootPoint.position.x)  == -1:
					$ShootPoint.position.x *= -1
	elif Input.is_action_pressed("ui_left") and !is_ducked and is_alive:
		if !is_attacking or !is_on_floor():
			velocity.x = -speed
			if !is_attacking:
				$Player_Anim.play("Run")
				$Player_Anim.flip_h = true
				if sign($ShootPoint.position.x) == 1:
					$ShootPoint.position.x *= -1
	else:
		velocity.x = 0
		if is_on_ground and !is_attacking and is_alive and !is_ducked:
			$Player_Anim.play("Idle")
		if is_on_ground and !is_attacking and is_alive and is_ducked:
			$Player_Anim.play("Duck")
			
	
#	VERTICAL MOVEMENT
	if Input.is_action_pressed("ui_up") and !is_ducked and is_on_ground and is_alive:
		if !is_attacking:
			velocity.y = JUMP_FORCE
			is_on_ground = false
#	DUCK MODE
	if Input.is_action_just_pressed("ui_down") and is_on_ground and is_alive:
		if !is_ducked:
			velocity.x = 0
			duck(true)
			$Player_Anim.play("Duck")
		elif is_ducked:
			duck(false)

		
#	SHOOT IF PLAYER HAS AMMO
	if Input.is_action_just_pressed("ui_select") and !is_attacking and is_alive:
		if ammo <= 0:
			return
		if is_on_floor():
			velocity.x = 0
		is_attacking = true
		reduce_one_from_ammo()
		if is_ducked:
			$Player_Anim.play("DuckShoot")
		else:
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


#SET DUCK ON/OFF
func duck(enabled:bool)->void:
	if enabled:
		is_ducked = true
		$Player_Hitbox.set_deferred("disabled", true)
		$Player_Duckbox.set_deferred("disabled", false)
		$ShootPoint.position.y = 1
	else:
		is_ducked = false
		$Player_Hitbox.set_deferred("disabled", false)
		$Player_Duckbox.set_deferred("disabled", true)
		$ShootPoint.position.y = -1
		
				
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
	
	
#ON PICKUP	
func on_pickup(pickup_type: String, gain: int):	
	if pickup_type == "HP":
		PlayerGlobals.set_hp(hp + gain)
		play_pickup(Color.white, Color.lime, 0.5, "HPPicked")
	elif pickup_type == "ARMOR":
		PlayerGlobals.set_armor(armor + gain)
		armor = PlayerGlobals.get_armor()
		play_pickup(Color.white, Color.yellow, 0.5, "ArmorPicked")
	elif pickup_type == "REGULARAMMO":
		PlayerGlobals.set_ammo(ammo + gain)
		ammo = PlayerGlobals.get_ammo()
		play_pickup(Color.white, Color.lightblue, 0.5, "AmmoPicked")
		

#PLAY PICKUP ANIMATION
func play_pickup(initial:Color, target:Color, duration:float, animation: String) -> void:		
		if !$PickupTween.is_active():
			$PickupTween.interpolate_property(self, "modulate", initial, target, duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$PickupTween.start()
			$PickupStopTimer.start()
			if !$Pick_Anim.is_playing():
				$Pick_Anim.visible = true
				$Pick_Anim.play(animation)

		
#IS THE ANIMATION DONE?
func _on_Player_Anim_animation_finished():
#	if !is_alive:
#		queue_free()
	is_attacking = false


#STOP HP PULSING
func _on_PulseStopTimer_timeout():
	$PulseTween.set_active(false)
	self.modulate = Color.white
	$PulseStopTimer.stop()


#STOP PICKUP PULSING
func _on_PickupStopTimer_timeout():
	$PickupTween.set_active(false)
	self.modulate = Color.white
	$PickupStopTimer.stop()


func _on_Pick_Anim_animation_finished():
	$Pick_Anim.stop()
	$Pick_Anim.visible = false
