class_name TerrainManager extends Node2D

@export var terrain_tile_map: TileMapLayer
@export var fence_tile_map: TileMapLayer

var world_size:Vector2 = Vector2(2000,2000)

func get_save_data()->Dictionary:
	return {}

func apply_save_data(data:Dictionary)->void:
	pass
