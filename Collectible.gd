extends Node2D

enum BONUS_TYPE {HP, HEALTH_REGEN, MOVE_SPEED, JUMP_SPEED, DAMAGE, DAMAGE_REDUCTION, DODGE, ATTACK_COOLDOWN}

export(int) var key
export(int) var bonus = 0
export(BONUS_TYPE) var bonus_type = 0 
export(float) var bonus_duration  = 0

onready var collectible_anim = $Collectible_Anim

var is_bonus_granted = false

func _ready():
	collectible_anim.play("Bounce")
	

#ON PLAYER COLLIDES WITH THE COLLECTIBLE
func on_collect(collector: KinematicBody2D):
	if is_bonus_granted:
		return
		
	if is_instance_valid(PlayerGlobals.player):
		if collector != PlayerGlobals.get_player():
			return
		else:
			grant_bonus(collector)
			is_bonus_granted = true
			self.visible = false
			collect(collector)


#ACTIONS TO TAKE WHEN COLLECTED
func collect(collector: KinematicBody2D):
	pass
	

#GRANT BONUS BY TYPE
func grant_bonus(collector: KinematicBody2D):
	match bonus_type:
		BONUS_TYPE.HP:
			grant_hp(collector, bonus, bonus_duration)
		BONUS_TYPE.HEALTH_REGEN:
			pass
		BONUS_TYPE.MOVE_SPEED:
			grant_move_speed(collector, bonus, bonus_duration)			
		BONUS_TYPE.JUMP_SPEED:
			grant_jump_speed(collector, bonus, bonus_duration)			
		BONUS_TYPE.DAMAGE:
			pass
		BONUS_TYPE.DAMAGE_REDUCTION:
			grant_damage_reduction(collector, bonus, bonus_duration)
		BONUS_TYPE.DODGE:
			pass
		BONUS_TYPE.ATTACK_COOLDOWN:
			grant_attack_cooldown(collector, bonus, bonus_duration)


#OVERRIDE THIS IN CHILD CLASS IF GRANTING HP
func grant_hp(collector:KinematicBody2D, hp_bonus:int, duration:float = 0.0):
	pass


#OVERRIDE THIS IN CHILD CLASS IF GRANTING MOVE SPEED
func grant_move_speed(collector:KinematicBody2D, speed_bonus:int, duration:float = 0.0):
	pass


#OVERRIDE THIS IN CHILD CLASS IF GRANTING JUMP SPEED
func grant_jump_speed(collector:KinematicBody2D, jump_bonus:int, duration:float = 0.0):
	pass


#OVERRIDE THIS IN CHILD CLASS IF GRANTING ATTACK COOLDOWN REDUCTION
func grant_attack_cooldown(collector:KinematicBody2D, attack_bonus:int, duration:float = 0.0):
	pass

#OVERRIDE THIS IN CHILD CLASS IF GRANTING DAMAGE REDUCTION
func grant_damage_reduction(collector:KinematicBody2D, reduction_bonus:int, duration:float = 0.0):
	pass
