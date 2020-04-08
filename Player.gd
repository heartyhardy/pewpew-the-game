extends KinematicBody2D

export(int) var hp = 100
export(int) var armor = 50
export(int) var ammo = 100
export(int) var speed = 50
export(int) var jump_speed = -250
export(int) var swim_speed = 20
export(int) var current_oxygen = 100
export(int) var max_oxygen = 100
export(int) var oxygen_consuption = 5

export(int) var buoyancy = 5

const GRAVITY = 650
const FLOOR = Vector2(0, -1)

var velocity = Vector2()
var submerged_velocity = Vector2()

var attack_mode = AttackMode.get_attack_mode()

var is_on_ground = false
var is_jumping = false
var is_attacking = false
var is_ducked = false
var is_alive = true
var is_taking_damage = false
var is_water_splashed = false
var is_grass_dodge_active = false
var is_tree_heal_active = false
var is_submerged = false
var is_out_of_breath = false

onready var oxygenbar = $OxygenBar

func _ready():

	PlayerGlobals.set("player", self)
	PlayerGlobals.set("hp", hp)
	PlayerGlobals.set("armor", armor)
	PlayerGlobals.set("ammo", ammo)
	PlayerGlobals.set("speed", speed)
	PlayerGlobals.set("jump_speed", jump_speed)
	PlayerGlobals.set("current_oxygen", current_oxygen)
	PlayerGlobals.set("maximum_oxygen", max_oxygen)	
	
	var tilemap_rect = get_parent().get_node("BaseLayer/TileMap").get_used_rect()
	var cell_size = get_parent().get_node("BaseLayer/TileMap").cell_size	
	
	$Player_Cam.limit_left = tilemap_rect.position.x * cell_size.x
	$Player_Cam.limit_right = tilemap_rect.end.x * cell_size.x
	$Player_Cam.limit_top = (tilemap_rect.position.y - 32) * cell_size.y
	$Player_Cam.limit_bottom = tilemap_rect.end.y * cell_size.y
	
	oxygenbar.on_max_oxygen_updated(PlayerGlobals.get_max_oxygen())
	oxygenbar.on_oxygen_updated(PlayerGlobals.get_max_oxygen())
	oxygenbar.visible = false


#INPUT EVENTS
func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_V:
				attack_mode = AttackMode.cycle_attack_mode() 
			KEY_1:
				process_attack_switch(1)				
			KEY_2:
				process_attack_switch(2)


#PROCESS ATTACK SWITCH KEY		
func process_attack_switch(attack_key:int):
	if attack_mode == AttackMode.ATTACK_MODES.MELEE:
		MeleeAttackTypes.set_current_attack(attack_key)
	elif attack_mode == AttackMode.ATTACK_MODES.RANGED:
		RangedAttackTypes.set_current_attack(attack_key)
		

#*** PHYSICS PROCESS ***
func _physics_process(delta):
	
#	IF DEAD DON'T PROCESS PHYSICS
	if !is_alive and is_on_floor():
		return
	
#	DETERMINE THE TILE PLAYER IS SITTING ON CURRENTLY
	var tile = get_colliding_tile()
	if tile[0] >= TileTypes.TILE_TYPES.TILE_WATER_SURFACE:
		is_submerged = true
		submerged_velocity.x = 0
		submerged_velocity.y = buoyancy
	elif tile[0] == TileTypes.TILE_TYPES.TILE_INVALID_TILE:
		is_submerged = false		
		
	
#	GROUND MOVEMENT
	if !is_submerged:
#		SET PLAYER GLOBAL STATE
		PlayerGlobals.set("is_on_ground", true)
		PlayerGlobals.set("is_submerged", false)
				
		handle_ground_movement(delta)
	elif is_submerged:		
#	UNDERWATER MOVEMENT
#		SET PLAYER GLOBAL STATE
		PlayerGlobals.set("is_on_ground", false)
		PlayerGlobals.set("is_submerged", true)				
		handle_underwater_movement(tile)
			
#	WATER SPLASH ON CONTACT
	water_splash()


#WATER SPLASH
func water_splash():
	if is_water_splashed:
		return
		
	var tile = get_colliding_tile()
	if tile[0] in [TileTypes.TILE_TYPES.TILE_WATER_SHALLOW, TileTypes.TILE_TYPES.TILE_WATER_SURFACE] and !is_on_floor():
		is_water_splashed = true
		var splash_pos = Vector2((tile[1].x * tile[2].cell_size.x)
		 + tile[2].cell_size.x/2, (tile[1].y * tile[2].cell_size.y) - 6)
#		GET WATER EFFECT FROM PRELOADER
		var splash = SpecialEffectTypes.get_special_effect(SpecialEffectTypes.EFFECT.WATER_SPLASH).instance()
		get_parent().add_child(splash)
		splash.position = splash_pos
	$WaterSplashTimer.start()
		
		
		
#GROUND MOVEMENT HANDLER
func handle_ground_movement(delta):
#	HIDE BUBBLES
	hide_water_bubbles()
	
#	HIDE OXYGEN BAR
	hide_oxygenbar()
	
	if attack_mode == AttackMode.ATTACK_MODES.MELEE and !$PassiveEffects/MinorHaste_Ani.visible:
		show_haste_effects()
	elif !attack_mode == AttackMode.ATTACK_MODES.MELEE:
		hide_haste_effects()
	
#	HORIZONTAL MOVEMENT
	if Input.is_action_pressed("ui_right") and !is_ducked and !is_taking_damage and is_alive:			
		if !is_attacking or !is_on_floor():
			velocity.x = lerp(velocity.x, PlayerGlobals.get_speed(), 0.1)
			if !is_attacking:
				$Player_Anim.play(Animations.get_animation("RUN", attack_mode))
				$Player_Anim.flip_h = false				
				if sign($ShootPoint.position.x)  == -1:
					$ShootPoint.position.x *= -1
					$MeleeHitPoint.position.x *= -1
					$PassiveEffects/MinorHaste_Ani.position *= -1
					$PassiveEffects/MinorHaste_Ani.flip_h = false					
	elif Input.is_action_pressed("ui_left") and !is_ducked and !is_taking_damage and is_alive:			
		if !is_attacking or !is_on_floor():
			velocity.x = lerp(velocity.x, -PlayerGlobals.get_speed(), 0.1)
			if !is_attacking:
				$Player_Anim.play(Animations.get_animation("RUN", attack_mode))
				$Player_Anim.flip_h = true	
				if sign($ShootPoint.position.x) == 1:
					$ShootPoint.position.x *= -1
					$MeleeHitPoint.position.x *= -1
					$PassiveEffects/MinorHaste_Ani.position *= -1
					$PassiveEffects/MinorHaste_Ani.flip_h = true
	else:
		velocity.x = lerp(velocity.x, 0, 0.2)
		if is_on_ground and !is_attacking and is_alive and !is_ducked and !is_taking_damage:
			$Player_Anim.play(Animations.get_animation("IDLE", attack_mode))
		if is_on_ground and !is_attacking and is_alive and is_ducked and !is_taking_damage:
			$Player_Anim.play(Animations.get_animation("DUCK", attack_mode))
#		HIDE HASTE EFFECT WHEN STATIONARY
		hide_haste_effects()
			
	
#	VERTICAL MOVEMENT
	if Input.is_action_pressed("ui_up") and !is_ducked and is_on_ground and is_alive:
		if !is_attacking:
			velocity.y = PlayerGlobals.get_jump_speed()
			is_jumping = true
			is_on_ground = false
	
#	CHECK IF PLAYER IS FALLING		
	if is_jumping and velocity.y > 0:
		is_jumping = false
		
#	DUCK MODE
	if Input.is_action_just_pressed("ui_down") and is_on_ground and is_alive:
		if !is_ducked:
			velocity.x = lerp(velocity.x, 0, 0.5)
			duck(true)
			$Player_Anim.play(Animations.get_animation("DUCK", attack_mode))
		elif is_ducked:
			duck(false)

		
#	SHOOT IF PLAYER HAS AMMO
	if Input.is_action_just_pressed("ui_select") and !is_attacking and is_alive:
#		IF ATTACK MODE IS MELEE
		if attack_mode == 1:
			handle_melee_attacks()
			return
#		IF ATTACK MODE IS GUN
		if attack_mode == 2:
			handle_gun_attacks()
			return
		
		
#	STOP ATTACK MODE
	if Input.is_action_just_released("ui_select"):
		if $Player_Anim.animation == "Shoot" or $Player_Anim.animation == "MeleeAttack":
			if !$Player_Anim.playing:
				is_attacking = false
		
	
#	PROCESSING GRAVITY
	velocity.y += GRAVITY * delta
	
#	IS PLAYER ON FLOOR?
	if is_on_floor() and is_alive:
		if !is_on_ground:
			is_attacking = false
		is_on_ground = true
	else:
		if !is_attacking and is_alive:
			is_on_ground = false
			if velocity.y < 0:
				$Player_Anim.play(Animations.get_animation("JUMP", attack_mode))
			else:
				$Player_Anim.play(Animations.get_animation("FALL", attack_mode))
	
#	SNAP SETTINGS
	var snap = Vector2(0, 8)
	if is_jumping:
		snap = Vector2()
		
	velocity = move_and_slide_with_snap(velocity, snap, FLOOR)


#UNDERWATERMOVEMENT HANDLER
func handle_underwater_movement(collided_tile: Array):
#	SHOW BUBBLES
	show_water_bubbles()
	
#	HIDE HASTE VISUAL EFFECT (DISABLING IT HAPPENS IN PASSIVESKILLS PHYSICS PROCESS)
	hide_haste_effects()
	
#	SHOW OXYGEN BAR
	show_oxygenbar()
	
	if $OxygenTimer.is_stopped():
		$OxygenTimer.start()
	
#	HORIZONTAL MOVEMENT
	if Input.is_action_pressed("ui_left"):
#		SHOW BUBBLES IN THE RIGHT PLACE
		if sign($BubblePosHorizontal.position.x) == 1:
			$BubblePosHorizontal.position.x *= -1
		$Bubbles_Anim.position = $BubblePosHorizontal.position
		$Player_Anim.play("Swim")
		$Player_Anim.flip_h = true
		submerged_velocity.x = -swim_speed
	elif Input.is_action_pressed("ui_right"):
#		POSITION BUBBLES CORRECTLY
		if sign($BubblePosHorizontal.position.x) == -1:
			$BubblePosHorizontal.position.x *= -1
		$Bubbles_Anim.position = $BubblePosHorizontal.position
		$Player_Anim.play("Swim")
		$Player_Anim.flip_h = false
		submerged_velocity.x = swim_speed
	else:
#		ON IDLE
		submerged_velocity.x = 0
		if !Input.is_action_pressed("ui_up") and !Input.is_action_pressed("ui_down") and !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
			if sign($BubblePosHorizontal.position.x) == -1:
				if sign($BubblesOrigin.position.x) != -1:
					$BubblesOrigin.position.x *= -1
			elif sign($BubblePosHorizontal.position.x) == 1:
				if sign($BubblesOrigin.position.x) != 1:
					$BubblesOrigin.position.x *= -1
			$Bubbles_Anim.position = $BubblesOrigin.position
			$Player_Anim.play("Float")
		
#	VERTICAL MOVEMENT
	if Input.is_action_pressed("ui_up"):
		if collided_tile[0] != TileTypes.TILE_TYPES.TILE_WATER_SURFACE:
			if Input.is_action_pressed("ui_up") and (!Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right")):
#				POSITION THE BUBBLES
				if sign($BubblePosVertical.position.y) == 1:
					$BubblePosVertical.position.y *= -1
				$Bubbles_Anim.position = $BubblePosVertical.position
				$Player_Anim.play("SwimUp")
			submerged_velocity.y += -swim_speed * 2
		elif collided_tile[0] == TileTypes.TILE_TYPES.TILE_WATER_SURFACE:			
			is_submerged = false
			velocity.y = PlayerGlobals.get_jump_speed()
			velocity = move_and_slide(velocity, FLOOR)
			return
	elif Input.is_action_pressed("ui_down"):
		if Input.is_action_pressed("ui_down") and (!Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right")):
#			POSITION THE BUBBLES
			if sign($BubblePosVertical.position.y) == -1:
				$BubblePosVertical.position.y *= -1
			$Bubbles_Anim.position = $BubblePosVertical.position
			$Player_Anim.play("SwimDown")
		submerged_velocity.y += swim_speed
	
	submerged_velocity.y += buoyancy
	submerged_velocity = move_and_slide(submerged_velocity, FLOOR)		
		
		
#MELEE ATTACKS HANDLER
func handle_melee_attacks():
	if !$MeleeCDTimer.is_stopped():
		return
		
	if !is_ducked:
		if is_on_floor():
#			LATER CHANGE THIS SO PLAYER CAN CHASE AND HIT
			velocity.x = 0
		is_attacking = true
		$Player_Anim.play("MeleeAttack")		
		var melee_punch = MeleeAttackTypes.get_current_attack().instance()
		melee_punch.set_direction(sign($MeleeHitPoint.position.x))
		get_parent().add_child(melee_punch)
		melee_punch.position = $MeleeHitPoint.global_position
		$MeleeCDTimer.wait_time = melee_punch.cooldown
		$MeleeCDTimer.start()
		
			
#GUN ATTACKS HANDLER
func handle_gun_attacks():
	if !$ShootCDTimer.is_stopped():
		return
		
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
	var weapon_projectile = RangedAttackTypes.get_current_attack().instance()
	weapon_projectile.set_direction(sign($ShootPoint.position.x))
	get_parent().add_child(weapon_projectile)
	weapon_projectile.position = $ShootPoint.global_position
	$ShootCDTimer.wait_time = weapon_projectile.cooldown
	$ShootCDTimer.start()	

#SET DUCK ON/OFF
func duck(enabled:bool)->void:
	if enabled:
		is_ducked = true
		Skills.enable_skill("DODGE")
		$Player_Hitbox.set_deferred("disabled", true)
		$Player_Duckbox.set_deferred("disabled", false)
		$ShootPoint.position.y = 1
	else:
		is_ducked = false
		Skills.disable_skill("DODGE")
		$Player_Hitbox.set_deferred("disabled", false)
		$Player_Duckbox.set_deferred("disabled", true)
		$ShootPoint.position.y = -1
		
				
#ON TAKE DAMAGE SEE IF PLAYER IS ALIVE AND UPDATE HP
func on_enemy_hit(dmg, dodged:bool = false, hit_direction = 0):
	if dodged:
		turn_towards_enemy(hit_direction)
		is_taking_damage = true
		$Player_Anim.play(Animations.get_animation("DODGE", attack_mode))
		return
	if !$PulseTween.is_active():
		$PulseTween.interpolate_property(self,"modulate", Color.white, Color.red, 0.5, Tween.TRANS_SINE,Tween.EASE_OUT)
		$PulseTween.start()
		$PulseStopTimer.start()
#	IGNORE ARMOR WHEN OUT OF BREATH
	if !is_out_of_breath:
		reduce_from_armor(dmg)
	else:
		reduce_from_hp(dmg)
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


#REDUCE DIRECTLY FROM HP
func reduce_from_hp(dmg):
	if is_alive:
		var current_hp = PlayerGlobals.get_hp()
		current_hp -= dmg
		PlayerGlobals.set_hp(current_hp)
		print_debug(PlayerGlobals.get_hp())
		hp = PlayerGlobals.get_hp()
				
		
#WHEN PLAYER DIES DO THESE
func on_player_death():
	$PulseTween.stop(self)
	$PulseStopTimer.stop()
	self.modulate = Color.white
	is_alive = false
	$Player_Anim.play(Animations.get_animation("DEATH", attack_mode))
	
	
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


#ON REGEN HP
func on_regen(amount):
	var current_hp = PlayerGlobals.get_hp()
	if current_hp < 100:
		PlayerGlobals.set_hp(current_hp + amount)
		hp = PlayerGlobals.get_hp()
		

#WHEN DODGED, TURN TOWARDS ENEMY ATTACK
func turn_towards_enemy(hit_direction):
	if hit_direction == sign($ShootPoint.position.x):
		if $Player_Anim.flip_h:
			$Player_Anim.flip_h = false
			$PassiveEffects/MinorHaste_Ani.flip_h = false
			if sign($PassiveEffects/MinorHaste_Ani.position.x) == 1:
				$PassiveEffects/MinorHaste_Ani.position.x *= -1
		elif !$Player_Anim.flip_h:
			$Player_Anim.flip_h = true
			$PassiveEffects/MinorHaste_Ani.flip_h = true
			if sign($PassiveEffects/MinorHaste_Ani.position.x) == -1:
				$PassiveEffects/MinorHaste_Ani.position.x *= -1	
		$ShootPoint.position.x *= -1
	

#IS PLAYER SUBMERGED/ NOT COUNTING SHALLOW WATER
func get_colliding_tile() -> Array:
	var collision_pos = self.global_position
	var tilemap = get_parent().get_node("BaseLayer/TileMap") as TileMap
	var tile_collision_pos = tilemap.world_to_map(collision_pos)
	var tile = tilemap.get_cellv(tile_collision_pos)
	return [tile, tile_collision_pos, tilemap]
	

#***** TOGGLE FUNCTIONS ***
					
#HIDE WATER BUBBLES
func hide_water_bubbles():
	if $Bubbles_Anim.visible:
		$Bubbles_Anim.stop()
		$Bubbles_Anim.visible = false


#SHOW WATER BUBBLES
func show_water_bubbles():
	if !$Bubbles_Anim.visible:
		$Bubbles_Anim.visible = true
		$Bubbles_Anim.play("Bubbles")


#HIDE HASTED ANIMATION WHEN NECESSARY
func hide_haste_effects():
	if $PassiveEffects/MinorHaste_Ani.visible:
		$PassiveEffects/MinorHaste_Ani.visible = false
		$PassiveEffects/MinorHaste_Ani.stop()
		$PassiveEffects/MinorHaste_Ani.frame = 0


#SHOW HASTED EFFECT		
func show_haste_effects():
	if !$PassiveEffects/MinorHaste_Ani.visible:	
		$PassiveEffects/MinorHaste_Ani.visible = true
		$PassiveEffects/MinorHaste_Ani.play("Hasted")


#SHOW OXYGEN BAR
func show_oxygenbar():
	if !oxygenbar.visible:
		max_oxygen = PlayerGlobals.get_max_oxygen()
		current_oxygen = max_oxygen
		PlayerGlobals.set_current_oxygen(max_oxygen)
		oxygenbar.on_max_oxygen_updated(PlayerGlobals.get_max_oxygen())
		oxygenbar.on_oxygen_updated(PlayerGlobals.get_max_oxygen())		
		oxygenbar.visible = true
		is_out_of_breath = false
		
		
#HIDE OXYGEN BAR		
func hide_oxygenbar():
	if oxygenbar.visible:
		oxygenbar.visible = false
		
#*** END OF TOGGLE FUNCTIONS ***

					
#IS THE ANIMATION DONE?
func _on_Player_Anim_animation_finished():
	if is_taking_damage:
		is_taking_damage = false
	if !is_alive:
		queue_free()
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


func _on_WaterSplashTimer_timeout():
	is_water_splashed = false


func _on_OxygenTimer_timeout():
	if !is_submerged:
		$OxygenTimer.stop()
		return
		
	if !is_alive:
		return
	
#	REDUCE OXYGEN	
	var oxygen = PlayerGlobals.get_current_oxygen()
	oxygen -= oxygen_consuption
	if oxygen > 0:
		is_out_of_breath = false
		current_oxygen = oxygen
		PlayerGlobals.set_current_oxygen(oxygen)
		oxygenbar.on_oxygen_updated(oxygen)	
	elif oxygen <= 0:
		is_out_of_breath = true
		current_oxygen = 0
		PlayerGlobals.set_current_oxygen(0)
		on_enemy_hit(oxygen_consuption)
		

