extends Node2D

const GRAVITY = 450
var origin = Vector2()
var velocity = Vector2()
var is_triggered = false
var is_falling = false

export(float) var crumble_time = 0.35
export(float) var respawn_time  = 10.0

onready var platform_raycasters = $Platform/Raycasters
onready var platform_hitbox = $Platform/Platform_Hitbox
onready var respawntimer = $RespawnTimer
onready var crumbletimer = $CrumbleTimer
onready var platform_anim = $Platform/Platform_Anim


func _ready():
	crumbletimer.wait_time = crumble_time
	respawntimer.wait_time = respawn_time
	origin = $Platform.global_position
	platform_anim.play("Idle")

func _physics_process(delta):
	if !is_triggered:
		for ray in platform_raycasters.get_children():
			if ray.is_colliding() and !platform_hitbox.disabled:				
				platform_anim.stop()
				crumbletimer.start()
				is_triggered = true			
			
	
	if is_triggered and is_falling:
		if !platform_hitbox.disabled:
			platform_hitbox.set_deferred("disabled", true)
		velocity.y += GRAVITY * delta
		$Platform.position = lerp($Platform.position, velocity, 0.075)							


func _on_RespawnNotifier_screen_exited():
	$RespawnTimer.start()


func _on_RespawnTimer_timeout():
	$Platform.global_position = origin
	is_triggered = false
	is_falling = false
	velocity = Vector2.ZERO
	platform_anim.stop()
	platform_anim.play("Respawn",true)
	platform_anim.visible = true


func _on_Platform_Anim_frame_changed():
	if platform_anim.animation == "Crumble":
		if !is_falling and platform_anim.frame == 3:
			is_falling = true


func _on_Platform_Anim_animation_finished():
	if platform_anim.animation == "Crumble":
		if is_falling:
			platform_anim.visible = false
	elif platform_anim.animation == "Respawn":
		platform_anim.play("Idle")
		platform_hitbox.set_deferred("disabled", false)
		
	
func _on_CrumbleTimer_timeout():
	platform_anim.play("Crumble")
