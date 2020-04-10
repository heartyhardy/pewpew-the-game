extends KinematicBody2D

export(int) var dodge_percentage = 75
export(int) var hits_to_trigger_skill_grant = 5

var remaining_hits = 5

onready var player = PlayerGlobals.get_player()
onready var baa_anim = $Baa_Anim
onready var info_bubble = $Info_Bubble
onready var hpbar = $HealthBar
onready var heal_timer = $HealTimer

var is_skill_granted = false

func _ready():
	var starting_hp = (remaining_hits / hits_to_trigger_skill_grant) * 100
	hpbar.on_maxhp_updated(starting_hp)
	hpbar.on_hp_updated(starting_hp)
	

func _physics_process(delta):
	self.set_meta("TAG", "BAABAA")
	look_at_player()
	

#LOOK AT PLAYER
func look_at_player():
	if !is_instance_valid(player):
		return
		
	var pos_diff = self.position.x -  player.position.x
	if sign(pos_diff) == -1:
		baa_anim.flip_h = true
	elif sign(pos_diff) == 1:
		baa_anim.flip_h = false


#GET DODGE PERCENTAGE
func get_dodge_percentage() -> int:
	return dodge_percentage
	

func reduce_from_hp():
	if remaining_hits > 1 and !is_skill_granted:
		remaining_hits -= 1
		var hp = remaining_hits / float(hits_to_trigger_skill_grant) * 100.0
		print(remaining_hits," ", hits_to_trigger_skill_grant, " ", hp)
		hpbar.on_hp_updated(hp)
	else:
		is_skill_granted = true
		if heal_timer.is_stopped():
			heal_timer.start()
	
#WHEN HIT BY A PLAYER ATTACK
func hit_by_player(damage:int, is_dodged:bool):
	if is_skill_granted:
		return
		
	if is_dodged:
		baa_anim.play("Dodge")
	else:
		baa_anim.play("Hit")
		reduce_from_hp()


func _on_Baa_Anim_animation_finished():
	match baa_anim.animation:
		"Dodge":
			baa_anim.play("Idle")
		"Hit":
			baa_anim.play("Idle")


#HEAL AFTER REACHING MIN HP
func _on_HealTimer_timeout():
	if remaining_hits < hits_to_trigger_skill_grant:
		remaining_hits += 1
		var hp = remaining_hits / float(hits_to_trigger_skill_grant) * 100.0
		hpbar.on_hp_updated(hp)
	else:
		heal_timer.stop()


#SHOW HIDE INFO BUBBLE
func show_info_bubble(is_shown:bool):
	if is_shown:
		info_bubble.visible = true
		hpbar.visible = false
	else:
		info_bubble.visible = false
		hpbar.visible = true


func _on_ActiveArea_body_entered(body):
	if body.name == "Player":
		show_info_bubble(false)


func _on_ActiveArea_body_exited(body):
	show_info_bubble(true)
