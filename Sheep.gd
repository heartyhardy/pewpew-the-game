extends KinematicBody2D

const SPEED = 20
const GRAVITY = 10
const FLOOR = Vector2(0, -1)

var STATES = ["Idle", "Walk"]
var TIMES = [15, 2]

var velocity = Vector2()
var direction = 1
var current_state: String = "Idle"

func _ready():
	$StateTimer.wait_time = TIMES[0]
	$Sheep_Anim.play(STATES[0])
	$StateTimer.start()

#PICK A RANDOM STATE
func pick_random_state() -> int:
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var state = rand.randi_range(1, len(STATES))
	return state-1


#TURN IF COLLIDED WITH A WALL
func turn():
	direction *= -1
	$LedgeDetectRay.position.x *= -1
	

func _physics_process(delta):
	if current_state != "Walk":
		return
		
	velocity.x = SPEED * direction
	velocity.y += GRAVITY
	
	if direction == -1:
		$Sheep_Anim.flip_h = true
	elif direction == 1:
		$Sheep_Anim.flip_h = false
	
	velocity = move_and_slide(velocity, FLOOR)
	
	if is_on_wall():
		turn()
	
	if !$LedgeDetectRay.is_colliding():
		turn()

#PICK A RANDOM STATE AND CHANGE TIMEOUT ACCORDINGLY
func _on_StateTimer_timeout():
	var state = pick_random_state()
	$StateTimer.stop()
	$StateTimer.wait_time = TIMES[state]
	current_state = STATES[state]
	$Sheep_Anim.play(STATES[state])
	$StateTimer.start()
