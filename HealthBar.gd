extends Control

onready var hpbar = $HPStatus
onready var hpbar_under = $HPDelayedStatus
onready var hptween = $HPTween
onready var pulsetween = $PulseTween

var green = Color("#87c51c")
var orange = Color("#f79b05")
var red = Color("#bf4523")
var pulse_color = Color.darkred

var orange_zone = 0.5
var red_zone = 0.25

#ON HP UPDATE
func on_hp_updated(new_hp):
	hpbar.value = new_hp
	hptween.interpolate_property(hpbar_under,"value", hpbar_under.value, new_hp, 0.3,Tween.TRANS_SINE,Tween.EASE_OUT, 0.4)
	hptween.start()
	
	set_hp_color(new_hp)
	
#ON MAXHP UPDATE
func on_maxhp_updated(maxhp):
	hpbar.max_value = maxhp
	hpbar_under.max_value = maxhp


func set_hp_color(new_hp):
	if new_hp <= hpbar_under.max_value * red_zone:		
		if !pulsetween.is_active():
			pulsetween.interpolate_property(hpbar,"tint_progress", pulse_color, red, 1.2, Tween.TRANS_SINE, Tween.EASE_OUT)
			pulsetween.start()
		else:
			hpbar.tint_progress = red
	else:
		pulsetween.set_active(false)
		if new_hp <= hpbar_under.max_value * orange_zone:
			hpbar.tint_progress = orange
		else:
			hpbar.tint_progress = green

