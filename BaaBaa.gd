extends KinematicBody2D

enum QUEST_STATE {NOT_STARTED, STARTED, COMPLETED, DISABLED}

export(int) var dodge_percentage = 75
export(int) var hits_to_trigger_skill_grant = 5

var remaining_hits = 5

onready var player = PlayerGlobals.get_player()
onready var baa_anim = $Baa_Anim
onready var info_bubble = $Info_Bubble
onready var hpbar = $HealthBar
onready var heal_timer = $HealTimer
onready var dialog_timer = $DialogTimer


var dialog_file = "res://dialogs/npcs/baabaa_dialog.json"
var dialog_root = null
var dialog_state = null
var is_skill_granted = false
var is_in_conversation = false
var speech_point = 0
var quest_state = QUEST_STATE.NOT_STARTED

func _ready():
	var starting_hp = (remaining_hits / hits_to_trigger_skill_grant) * 100
	hpbar.on_maxhp_updated(starting_hp)
	hpbar.on_hp_updated(starting_hp)
	
	dialog_root = JSONLoader.read_json(dialog_file)
	dialog_state = dialog_root
	info_bubble.play("Info")
	

func _physics_process(delta):
	self.set_meta("TAG", "BAABAA")
	look_at_player()

	match quest_state:
		QUEST_STATE.NOT_STARTED:
			if !is_in_conversation:
				PlayerGlobals.set_cutscene_mode(false)
		QUEST_STATE.STARTED:
			exit_conversation()
			show_info_bubble(false)
			PlayerGlobals.set_cutscene_mode(false)
		QUEST_STATE.COMPLETED:
			if !is_skill_granted:
				is_skill_granted = true
				speech_point += 1
				dialog_state[str(speech_point)]["unlocked"] = true
				start_conversation()
				
	

#LOOK AT PLAYER
func look_at_player():
	if !is_instance_valid(player):
		return
		
	var pos_diff = self.position.x -  player.position.x
	if sign(pos_diff) == -1:
		baa_anim.flip_h = true
	elif sign(pos_diff) == 1:
		baa_anim.flip_h = false


#CONVERSATION HANDLER
func converse():
	if quest_state == QUEST_STATE.DISABLED or quest_state == QUEST_STATE.STARTED:
		return
		
	var current_speech
	var all_completed = false
	var speeches = dialog_state[str(speech_point)]["speech"]
	var is_unlocked = dialog_state[str(speech_point)]["unlocked"]
	
	for i in len(speeches):
		if !speeches[i]["completed"] and is_unlocked:
			all_completed = false
			current_speech = speeches[i]["caption"]
			speeches[i]["completed"] = true
			break
		else:
			all_completed = true
	
	if current_speech != null:
		DialogMediator.set_speaker(dialog_root["speaker"])
		DialogMediator.set_captions(current_speech)
		
	if all_completed:
		var has_next = dialog_state.has(str(speech_point+1))		
		if has_next:
			var next = dialog_state[str(speech_point+1)]
			var has_resume = next.has("resume")

			if next["unlocked"]:
				speech_point += 1
			elif !next["unlocked"] and has_resume and next["resume"]:
				speech_point += 1
				next["resume"] = true
				next["unlocked"] = true			
				exit_conversation()
			else:
				exit_conversation()
				DialogMediator.set_dialogui_visibility(false)
		else:
			quest_state = QUEST_STATE.DISABLED
			info_bubble.play("Complete")
			PlayerGlobals.set_cutscene_mode(false)
			exit_conversation()
	
	
#STARTS THE CONVERSATION
func start_conversation():
	#	LOCK PLAYER CONTROLS
	PlayerGlobals.set_cutscene_mode(true)
	
	show_info_bubble(false)
	if dialog_timer.is_stopped():
		is_in_conversation = true		
		dialog_timer.start()
		

#RESETS THE CONVERSATION TO CURRENT BRANCH
func reset_conversation():
	var speeches = dialog_state[str(speech_point)]["speech"]
	for i in len(speeches):
		speeches[i]["completed"] = false
				

#EXIT CONVERSATION MODE
func exit_conversation():
	is_in_conversation = false
	dialog_timer.stop()
	reset_conversation()
	show_info_bubble(true)
	DialogMediator.set_dialogui_visibility(false)
	
	#	LOCK PLAYER CONTROLS
	PlayerGlobals.set_cutscene_mode(false)


#GET DODGE PERCENTAGE
func get_dodge_percentage() -> int:
	return dodge_percentage
	

#REDUCE FROM BAA's HP
func reduce_from_hp():
	if remaining_hits > 1 and !is_skill_granted:
		remaining_hits -= 1
		var hp = remaining_hits / float(hits_to_trigger_skill_grant) * 100.0
		hpbar.on_hp_updated(hp)
	else:
		quest_state = QUEST_STATE.COMPLETED
		if heal_timer.is_stopped():
			heal_timer.start()
			
	
#WHEN HIT BY A PLAYER ATTACK
func hit_by_player(damage:int, is_dodged:bool):
	if is_skill_granted:
		return
		
	if quest_state == QUEST_STATE.NOT_STARTED:
		quest_state = QUEST_STATE.STARTED
		
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
	if is_in_conversation or quest_state == QUEST_STATE.STARTED or quest_state == QUEST_STATE.DISABLED:
		return		
		
	if body.name == "Player":
		start_conversation()


func _on_ActiveArea_body_exited(body):
	exit_conversation()
	


func _on_DialogTimer_timeout():
	if !DialogMediator.is_dialog_visible():
		DialogMediator.set_dialogui_visibility(true)
	converse()
