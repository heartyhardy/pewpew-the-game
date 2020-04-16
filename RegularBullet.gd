extends Area2D

export(int) var speed = 200
export(int) var damage = 10
export(float) var cooldown = 0.35

var velocity = Vector2()
var direction = 1

onready var tilemap = get_parent().get_node("BaseLayer/TileMap")


func _ready():
	pass # Replace with function body.

#Change Direction
func set_direction(dir):
	direction = dir
	if direction == -1:
		$Bullet_Anim.flip_h = true
	else:
		$Bullet_Anim.flip_h = false

func _physics_process(delta):
	velocity.x = speed * delta * direction
	translate(velocity)
	$Bullet_Anim.play("BulletFired")
	
#	DETECT BREAKABLE TILES
	detect_breakable_tiles()	


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


#RELEASE IF OUT OF SCREEN
func _on_Bullet_Visibility_screen_exited():
	queue_free()


#RELEASE IF COLLIDE
func _on_RegularBullet_body_entered(body):
	if body.name != 'TileMap':		
		var b_type = body.get_meta('TAG')
		match b_type:
			"ENEMY":
				if body.has_method("hit_by_player"):
					body.hit_by_player(damage)
			"NPC_ATTACKABLE":
				if body.has_method("hit_by_player") and body.has_method("get_dodge_percentage"):
					var is_dodged = SkillChecks.can_dodge(body.get_dodge_percentage())
					if is_dodged:
						body.hit_by_player(damage, is_dodged)
						return
					else:
						body.hit_by_player(damage, false)		
	queue_free()
