extends "res://Collectible.gd"


#THIS IS CALLED INTERNALLY FROM THE PARENT CLASS's on_collect()
func collect(collector:KinematicBody2D):
	pass


func _on_Cherries_body_entered(body):
	if body is KinematicBody2D:
		on_collect(body)


#OVERRIDE THIS IN CHILD CLASS IF GRANTING MOVE SPEED
func grant_move_speed(collector:KinematicBody2D, speed_bonus:int, duration:float = 0.0):
	print("MOVE SPEED BEFORE", " ", PlayerGlobals.get_speed())
	PlayerGlobals.set_speed(PlayerGlobals.get_speed() + speed_bonus)
	print("MOVE SPEED GRANTED", " ", PlayerGlobals.get_speed())
	
	var treducer = Timer.new()
	treducer.wait_time = duration
	add_child(treducer)
	treducer.connect("timeout", self, "on_bonus_end_timeout",[speed_bonus])
	treducer.start()
	
	
func on_bonus_end_timeout(speed_bonus:int):
	PlayerGlobals.set_speed(PlayerGlobals.get_speed() - speed_bonus)
	print(PlayerGlobals.get_speed())
	queue_free()
