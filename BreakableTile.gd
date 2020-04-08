extends Node2D

var tile_above = Vector2()
var _tilemap

func on_tile_break(tilemap:TileMap, tilepos:Vector2, animation:String):	
	_tilemap = tilemap
	var pos = tilemap.map_to_world(tilepos)
	global_position = Vector2(pos.x + 8, pos.y + 8)	
	$Tile_Anim.play(animation)


func _on_Tile_Anim_animation_finished():
	queue_free()
