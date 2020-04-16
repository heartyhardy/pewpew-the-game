extends Control

const start_color = Color(1.0, 1.0, 1.0, 0.75)
const end_color = Color(1.0, 1.0, 1.0, 0.0)

onready var pulse_tween = $PulseTween
onready var overlay = $DamageOverlay

const MAX_PULSES = 2
var remaining_pulses = 2


func _ready():
	self.visible = false
	remaining_pulses = MAX_PULSES

	
#PULSE N TIMES AND STOP
func pulse():
	if pulse_tween.is_active():
		return
		
	if !self.visible:
		self.visible = true		
	
	pulse_tween.interpolate_property(overlay, "modulate", start_color, end_color, 0.3,Tween.TRANS_SINE,Tween.EASE_IN_OUT )
	pulse_tween.interpolate_property(overlay, "modulate", end_color, start_color, 0.15,Tween.TRANS_SINE,Tween.EASE_IN_OUT )
	pulse_tween.start()


func _on_PulseTween_tween_completed(object, key):
	if remaining_pulses > 0:
		remaining_pulses -= 1
	else:
		remaining_pulses = MAX_PULSES
		self.visible = false


#ON PLAYER DAMAGE, PULSE
func _on_Player_on_player_hit():
	pulse()
