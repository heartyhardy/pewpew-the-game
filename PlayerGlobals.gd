extends Node2D

#PLAYER OBJECT
var player

#PLAYER PROPERTIES
var hp
var armor
var ammo

func _ready():
	pass
	
#GET PLAYER
func get_player():
	return player
	

#GET PLAYER HP
func get_hp():
	return hp
	
	
#GET PLAYER ARMOR
func get_armor():
	return armor
	

#GET PLAYER AMMO
func get_ammo():
	return ammo
	

#SET PLAYER HP
func set_hp(player_hp):
	if player_hp < 0:
		hp = 0
	elif player_hp > 100:
		hp = 100
	else:
		hp = player_hp
		

#SET PLAYER ARMOR
func set_armor(player_armor):
	if player_armor < 0:
		armor = 0
	elif player_armor > 100:
		armor = 100
	else:
		armor = player_armor
		
		
#SET PLAYER AMMO
func set_ammo(player_ammo):
	if ammo < 0:
		ammo = 0
	elif ammo > 999:
		ammo = 999
	else:
		ammo = player_ammo
		
