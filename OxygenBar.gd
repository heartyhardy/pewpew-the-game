extends Control

export(bool) var hide_when_zero = true

onready var oxygenbar = $OxygenStatus
onready var oxygenbar_under = $OxygenDelayedStatus
onready var oxygen_tween = $OxygenTween

onready var low_color = Color("#202a5a")
onready var medium_color = Color("#215b92")
onready var high_color = Color("#0eaed0")

var medium_range = 0.5
var low_range = 0.25


#ON OXYGEN CHANGE
func on_oxygen_updated(new_oxygen:int):
	oxygenbar.value = new_oxygen
	oxygen_tween.interpolate_property(oxygenbar_under, "value", oxygenbar_under.value, new_oxygen, 0.3, Tween.TRANS_SINE,Tween.EASE_OUT)
	oxygen_tween.start()
	
	set_color(new_oxygen)


#SET MAX OXYGEN VALUE
func on_max_oxygen_updated(max_oxygen:int):
	oxygenbar.max_value = max_oxygen
	oxygenbar_under.max_value = max_oxygen


#SET PROGRESS COLOR
func set_color(new_oxygen:int):
	if new_oxygen <= oxygenbar_under.max_value * low_range:
		oxygenbar.tint_progress = low_color
	elif new_oxygen <= oxygenbar_under.max_value * medium_range:
		oxygenbar.tint_progress = medium_color
	else:
		oxygenbar.tint_progress = high_color

	
#ON TWEEN COMPLETE
func _on_OxygenTween_tween_completed(object, key):
	if oxygenbar.value <= 0 and hide_when_zero:
		self.visible = false
