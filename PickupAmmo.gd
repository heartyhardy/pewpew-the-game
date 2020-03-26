extends Area2D

export(int) var ammo_gain = 10

func _ready():
	set_meta("TAG", "PICKUP")
	$BounceAnimation.play("Bounce")


#WHEN PLAYER ENTERS THE AREA, PICKUP
func _on_PickupRegularAmmo_body_entered(body: PhysicsBody2D) -> void:
	if is_instance_valid(body):
		body.on_pickup("REGULARAMMO", ammo_gain)
		queue_free()
