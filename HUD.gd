extends Control

var player

#TEXT COLORS
var green = Color("#87c51c")
var orange = Color("#f79b05")
var red = Color("#bf4523")

func _on_Player_ready():
	player = PlayerGlobals.player

# warning-ignore:unused_argument
func _physics_process(delta):
	
#	UPDATE LABEL TEXT AND COLORS
	var hp = PlayerGlobals.get_hp()
	var armor = PlayerGlobals.get_armor()
	var ammo = PlayerGlobals.get_ammo()	
	
	set_label_color($StatusBar/AmmoCounter/Label, ammo)
	set_label_color($StatusBar/ArmorCounter/Label, armor)
	set_label_color($StatusBar/HealthCounter/Label, hp)
	
	$StatusBar/HealthCounter/Label.text = str(PlayerGlobals.get_hp())
	$StatusBar/ArmorCounter/Label.text = str(PlayerGlobals.get_armor())
	$StatusBar/AmmoCounter/Label.text = str(PlayerGlobals.get_ammo())


#SET COLOR TO THE GIVEN LABEL DEPENDING ON THE NUMBER
func set_label_color(lbl, num):
	if num <= 100 and num > 50:
		lbl.add_color_override("font_color", green)
		$HPBlinkTimer.paused = true
	elif num <= 50 and num > 20:
		lbl.add_color_override("font_color", orange)
		$HPBlinkTimer.paused = true		
	elif num <= 20:
		lbl.add_color_override("font_color", red)
		if $HPBlinkTimer.paused:
			$HPBlinkTimer.paused = false
		elif $HPBlinkTimer.is_stopped():
			$HPBlinkTimer.start()


func _on_Timer_timeout():
	var hp = PlayerGlobals.get_hp()
	if hp <= 50:
		var is_visible = $StatusBar/HealthCounter/Icon.visible
		if is_visible:
			$StatusBar/HealthCounter/Icon.visible = false
		elif !is_visible:
			$StatusBar/HealthCounter/Icon.visible = true
			
