extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)

export(int) var speed = 40
export(int) var hp = 50
export(int) var damage = 50

var prev_speed = speed
var velocity = Vector2()
var direction = 1
var is_attacking = false
var is_alive = true

onready var hpbar = $HealthBar 

#SET TYPE TO ENEMY
func _ready():
	self.set_meta('TAG','ENEMY')
	hpbar.on_maxhp_updated(hp)	

func _physics_process(delta):
	
	if !is_alive:
		return
	
#	IF NOT ATTACKING MOVE NORMALLY OR MOVE 2X FASTER
	if !is_attacking:
		velocity.x = speed * direction
	elif is_attacking:
		velocity.x = speed * 2 * direction
		
	velocity.y += GRAVITY
	
#	FLIP SPRITE WHEN DIRECTION CHANGES
	if direction == -1:
		$Spider_Anim.flip_h = true
	else:
		$Spider_Anim.flip_h = false
	
#	CHANGE ANIMATION DEPENDING ON STATE
	if !is_attacking:
		$Spider_Anim.play("Patrol")
		$VisonRay.cast_to = Vector2(direction * 50,0)
	elif is_attacking:
		$Spider_Anim.play("Attack")
		$VisonRay.cast_to = Vector2(direction * 100,0)
		
		
	velocity = move_and_slide(velocity, FLOOR)
	
#	CHANGE RAYCASTING DIRECTION
	if is_on_wall():
		turn()
	
#	IF PLAYER IS BEING DETECTED ATTACK
	if $VisonRay.is_colliding():
		if $VisonRay.get_collider().name == "Player":
			is_attacking = true
	else:
		is_attacking = false

#	IF LEDGE IS DETECTED CHANGE RAYCASTING DIRECTION
	if !$LedgeDetectRay.is_colliding() and !is_attacking:
		turn()
		
#	IF PLAYER GETS HIT THEN EXPLODE
	if get_slide_count() > 0:
		for i in (get_slide_count()):
			if "Player" in get_slide_collision(i).collider.name:
				is_alive = false
				hpbar.on_hp_updated(0)
				$Spider_Hitbox.set_deferred("disabled", true)
				$Spider_Anim.play("Explode")
				get_slide_collision(i).collider.on_enemy_hit(damage)
		

func turn():
	direction *= -1
	$LedgeDetectRay.position.x *= -1
	$VisonRay.position.x *= -1
	$VisonRay.cast_to *= -1

#ON PLAYER HIT, TURN IF NECESSARY
func hit_by_player(dmg):
	hp -= dmg
	hpbar.on_hp_updated(hp)
	if should_turn():
		turn()
	if hp <= 0:
		is_alive = false
		$Spider_Hitbox.set_deferred("disabled", true)
		$Spider_Anim.play("Death")

#WHEN GETS HIT BY PLAYER FROM BEHIND, TURN BACK
func should_turn():
	var player_pos = PlayerGlobals.get("player").position.x
	if player_pos < position.x and sign($VisonRay.position.x) == 1:
		return true
	if player_pos > position.x and sign($VisonRay.position.x) == -1:
		return true
	return false

#QUEUE FREE IF DEAD
func _on_Spider_Anim_animation_finished():
	if !is_alive:
		queue_free()
