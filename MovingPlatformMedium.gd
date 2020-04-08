extends Node2D

const TILE_SIZE = 16

export(int) var idle_time = 2.0
export(int) var move_speed = 3
export(Vector2) var move_to = Vector2.RIGHT * 32

var move_helper = Vector2.ZERO

onready var platform = $Platform
onready var movetween = $MoveTween

func _ready():
	_set_movement()
	

func _set_movement():
	var move_duration  = move_to.length() / float(move_speed * TILE_SIZE)
	movetween.interpolate_property(self, "move_helper", Vector2.ZERO, move_to, move_duration, Tween.TRANS_LINEAR, Tween.EASE_IN, idle_time)
	movetween.interpolate_property(self, "move_helper", move_to, Vector2.ZERO, move_duration, Tween.TRANS_LINEAR, Tween.EASE_IN, move_duration + idle_time * 2)
	movetween.start()


func _physics_process(delta):
	platform.position = platform.position.linear_interpolate(move_helper, 0.075)
