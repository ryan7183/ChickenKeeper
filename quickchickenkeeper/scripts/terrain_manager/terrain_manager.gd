class_name TerrainManager extends Node2D

@export var terrain_tile_map: TileMapLayer
@export var fence_tile_map: TileMapLayer

signal tile_placed

enum TerrainType {GRASS, DIRT, WATER, FENCE, NOTHING}

const initial_island_size:int = 10

var disable_tile_placement:bool = false
var placement_mode:TerrainType = TerrainType.NOTHING

var world_size:Vector2 = Vector2(2000,2000)
var terrain_map:Array[Array] = []
var changed_tile_map:Array[Array] = []
var fence_map:Array[Array] = []
var tile_size:int = 16

var grass_grower:GrassGrower
var keep_placing_tiles:bool = false

func _ready() -> void:
	grass_grower = GrassGrower.new()
	pass

func _process(delta: float) -> void:
	var results:Dictionary = grass_grower.grow_grass(delta)
	terrain_map = results["terrain"]
	changed_tile_map = results["changed"]
	update_tile_map(results["changed"])
	if keep_placing_tiles:
		_place_tile()
	pass

func update_tile_map(changed:Array[Array])->void:
	# Find list of water tiles
	var water_list:Array[Vector2i] = []
	# Find list of grass tiles
	var grass_list:Array[Vector2i] = []
	# Find list of dirt tiles
	var dirt_list:Array[Vector2i] = []
	for x:int in world_size.x:
		for y: int in world_size.y:
			if changed[x][y] as bool:
				#terrain_tile_map.set_cell(Vector2i(x,y),0,Vector2i(1,4))
				match terrain_map[x][y]:
					TerrainType.GRASS:
						grass_list.append(Vector2i(x,y))
					TerrainType.DIRT:
						dirt_list.append(Vector2i(x,y))
					TerrainType.WATER:
						water_list.append(Vector2i(x,y))
				pass
	if water_list.size()>0:
		terrain_tile_map.set_cells_terrain_connect(water_list,0,2)
	if grass_list.size()>0:
		terrain_tile_map.set_cells_terrain_connect(grass_list,0,1)
	if dirt_list.size()>0:
		terrain_tile_map.set_cells_terrain_connect(dirt_list,0,0)
	pass

func _input(event: InputEvent) -> void:
	if placement_mode != TerrainType.NOTHING:
		if event.is_action_pressed("PlaceTile") and !disable_tile_placement:
			keep_placing_tiles = true
			pass
		elif event.is_action_released("PlaceTile") or disable_tile_placement:
			keep_placing_tiles = false
	pass

func _place_tile()->void:
	var tile_pos:Vector2i = terrain_tile_map.local_to_map(to_local(get_global_mouse_position()))
	if tile_pos.x>=0 and tile_pos.y>=0 and tile_pos.x<world_size.x and tile_pos.y<world_size.y:
		terrain_map[tile_pos.x][tile_pos.y] = placement_mode
		match placement_mode:
			TerrainType.GRASS:
				terrain_tile_map.set_cells_terrain_connect([Vector2i(tile_pos.x,tile_pos.y)],0,1)
			TerrainType.DIRT:
				terrain_tile_map.set_cells_terrain_connect([Vector2i(tile_pos.x,tile_pos.y)],0,0)
			TerrainType.WATER:
				terrain_tile_map.set_cells_terrain_connect([Vector2i(tile_pos.x,tile_pos.y)],0,2)
		tile_placed.emit()
		grass_grower.update_data(terrain_map)
	pass



func setup_terrain()->void:
	grass_grower.update_data(terrain_map)
	# Find list of water tiles
	var water_list:Array[Vector2i] = []
	# Find list of grass tiles
	var grass_list:Array[Vector2i] = []
	# Find list of dirt tiles
	var dirt_list:Array[Vector2i] = []
	for x:int in world_size.x:
		for y: int in world_size.y:
			terrain_tile_map.set_cell(Vector2i(x,y),0,Vector2i(1,4))
			match terrain_map[x][y]:
				TerrainType.GRASS:
					grass_list.append(Vector2i(x,y))
				TerrainType.DIRT:
					dirt_list.append(Vector2i(x,y))
				TerrainType.WATER:
					water_list.append(Vector2i(x,y))
			pass
	terrain_tile_map.set_cells_terrain_connect(water_list,0,2)
	terrain_tile_map.set_cells_terrain_connect(grass_list,0,1)
	terrain_tile_map.set_cells_terrain_connect(dirt_list,0,0)
	pass

func generate_initial_island()->void:
	for x:int in world_size.x:
		var col:Array[TerrainType] = []
		for y:int in world_size.y:
			col.append(TerrainType.WATER)
			pass
		terrain_map.append(col)
	
	@warning_ignore("integer_division")
	var center:Vector2i = Vector2i(world_size/2.0)
	@warning_ignore("integer_division")
	for x:int in range(-initial_island_size/2,initial_island_size/2):
		@warning_ignore("integer_division")
		for y:int in range(-initial_island_size/2,initial_island_size/2):
			terrain_map[center.x+x][center.y+y] = TerrainType.GRASS
			pass
	
	pass

func get_save_data()->Dictionary:
	return {
		"terrain_map" : terrain_map,
		"fence_map":fence_map,
	}

func apply_save_data(data:Dictionary)->void:
	terrain_map = []#data["terrain_map"] as Array[Array]
	for array:Array in data["terrain_map"]:
		var col:Array[int] = []
		for value:int in array:
			col.append(value)
		terrain_map.append(col)
		
	fence_map = []#data["fence_map"] as  Array
	fence_map.resize(data["fence_map"].size())
	for array:Array in data["fence_map"]:
		fence_map.append(array)
		pass
	pass
