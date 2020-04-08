extends Area2D

export(int) var damage = 25
export(float) var cooldown = 0.35

const SPEED = 50

var distance = 0
var velocity = Vector2()
var direction = 1

onready var tilemap = get_parent().get_node("BaseLayer/TileMap")


func _ready():
	$Punch_Anim.play("Punch")
	

#SET PROJECTILE DIRECTION
func set_direction(dir:int):
	direction = dir
	if direction == 1:
		$Punch_Anim.flip_h = false
	elif direction == -1:
		$Punch_Anim.flip_h = true
		

func _physics_process(delta):
	distance += SPEED
	velocity.x = SPEED * delta * direction
	translate(velocity)	
	
#	DETECT BREAKABLE TILES
	detect_breakable_tiles()
	
	if distance > 150:
		queue_free()
	
	
#DETECT_BREAKABLE TILES
func detect_breakable_tiles():
	var collided_tile_v = tilemap.world_to_map(self.global_position)
	find_all_breakables_vertical(collided_tile_v)	


#FIND ALL BREAKABLE TILES (VERTICAL AXIS) AND DESTROY THEM
func find_all_breakables_vertical(collided_tile: Vector2):
	var next_tile_pos = collided_tile
	var next_tile = tilemap.get_cellv(next_tile_pos)
	
	while next_tile in [TileTypes.TILE_TYPES.TILE_BREAKABLE_TYPE1, TileTypes.TILE_TYPES.TILE_BREAKABLE_TYPE2]:
		match next_tile:
			TileTypes.TILE_TYPES.TILE_BREAKABLE_TYPE1:
				destroy_breakable_tile(next_tile_pos, TileTypes.TILE_TYPES.TILE_BREAKABLE_TYPE1_ANI)
			TileTypes.TILE_TYPES.TILE_BREAKABLE_TYPE2:
				destroy_breakable_tile(next_tile_pos, TileTypes.TILE_TYPES.TILE_BREAKABLE_TYPE2_ANI)

		next_tile_pos = Vector2(next_tile_pos.x, next_tile_pos.y -1 )
		next_tile = tilemap.get_cellv(next_tile_pos)
	
	
#DESTROY AND PLAY ANIMATED TILE ON SPOT
func destroy_breakable_tile(tilepos: Vector2, tile_index:int):
	tilemap.set_cellv(tilepos, -1)
	var tile = SpecialEffectTypes.get_special_effect(SpecialEffectTypes.EFFECT.BREAKABLE_TILE).instance()
	get_parent().add_child(tile)
	tile.on_tile_break(tilemap, tilepos, str(tile_index))
	

func _on_MeleeDefaultPunch_body_entered(body):
	if body.name != 'TileMap':
		var b_type = body.get_meta("TAG")
		if b_type == "ENEMY":
			body.hit_by_player(damage)
#	queue_free()
