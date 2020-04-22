extends "res://Collectible.gd"


#THIS IS CALLED INTERNALLY FROM THE PARENT CLASS's on_collect()
func collect(collector:KinematicBody2D):
	queue_free()


func _on_Orange_body_entered(body):
	if body is KinematicBody2D:
		on_collect(body)
