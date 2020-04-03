extends Area2D

onready var rand = RandomNumberGenerator.new()

func _ready():
	gen_z_index()
	gen_start_frame()
	
#GENERATE A RANDOM Z-INDEX
func gen_z_index():
	rand.randomize()
	var zindex = rand.randi_range(-1,0)
	$Seaweed_Anim.z_index = zindex
	

func gen_start_frame():
	rand.randomize()
	var frames = $Seaweed_Anim.frames.get_frame_count("Idle")
	var start_frame = rand.randi_range(0, frames)
	print_debug(start_frame)
	$Seaweed_Anim.stop()
	$Seaweed_Anim.frame = start_frame
	$Seaweed_Anim.play("Idle")
