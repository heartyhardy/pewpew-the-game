extends Area2D

export(int) var armor_gain = 10

func _ready():
	set_meta("TAG", "PICKUP")
	$BounceAnimation.play("Bounce")


#WHEN PLAYER ENTERS THE AREA, PICKUP
func _on_PickupArmor_body_entered(body: PhysicsBody2D) -> void:
		if is_instance_valid(body):
			body.on_pickup("ARMOR", armor_gain)
			queue_free()
