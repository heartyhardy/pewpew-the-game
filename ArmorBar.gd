extends Control

export(bool) var hide_when_zero = true

onready var armorbar = $ArmorStatus
onready var armorbar_under = $ArmorDelayedStatus
onready var armor_tween = $ArmorTween

onready var low_color = Color("#bd6604")
onready var medium_color = Color("#f79b05")
onready var high_color = Color("#d6ca6e")

var medium_range = 0.5
var low_range = 0.25

#ON ARMOR CHANGE
func on_armor_updated(new_armor):
	armorbar.value = new_armor
	armor_tween.interpolate_property(armorbar_under, "value", armorbar_under.value, new_armor, 0.3,Tween.TRANS_SINE, Tween.EASE_OUT)
	armor_tween.start()
	
	set_color(new_armor)

#ON MAX ARMOR CHANGE
func on_max_armor_updated(max_armor):
	armorbar.max_value = max_armor
	armorbar_under.max_value = max_armor


#ON TWEEN COMPLETED
func _on_ArmorTween_tween_completed(object, key):
	if armorbar.value <= 0 and hide_when_zero:
		self.visible = false

#SET ARMOR BAR COLOR DEPENDING ON REMAINING ARMOR
func set_color(new_armor):
	if new_armor <= armorbar_under.max_value * low_range:
		armorbar.tint_progress = low_color
	elif new_armor <= armorbar_under.max_value * medium_range:
		armorbar.tint_progress = medium_color
	else:
		armorbar.tint_progress = high_color
