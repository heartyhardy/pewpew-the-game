extends Area2D

export(int) var hp_gain = 10

func _ready():
	set_meta("TAG", "PICKUP")
	$BounceAnimation.play("Bounce")


#WHEN PLAYER ENTERS THE AREA, PICKUP
func _on_PickupHP_body_entered(body: PhysicsBody2D) -> void:
	if is_instance_valid(body):
		body.on_pickup("HP", hp_gain)
		queue_free()
