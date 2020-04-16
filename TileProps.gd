extends Node2D

var json_path = "res://tileprops/tileprops.json"
var tile_props_json = null

func _ready():
	tile_props_json = JSONLoader.read_json(json_path)
	
	
#GET TILE PROPS
func get_props(prop_id:int):
	if tile_props_json.has(str(prop_id)):
		return tile_props_json[str(prop_id)]
