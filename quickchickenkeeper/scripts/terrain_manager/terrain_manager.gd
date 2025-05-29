class_name TerrainManager extends Node2D

@export var terrain_tile_map: TileMapLayer
@export var fence_tile_map: TileMapLayer

@export var grass_place_audio:AudioStreamPlayer2D
@export var dirt_place_audio:AudioStreamPlayer2D
@export var water_place_audio:AudioStreamPlayer2D
@export var fence_place_audio:AudioStreamPlayer2D

signal tile_placed

enum TerrainType {GRASS, DIRT, WATER, FENCE, REMOVE_FENCE, NOTHING}

const initial_island_size:int = 10

var disable_tile_placement:bool = false
var placement_mode:TerrainType = TerrainType.NOTHING

var world_size:Vector2 = Vector2(2000,2000)
var terrain_map:Array[Array] = []
var food_amount:Array[Array] = []
var fence_map:Array[Array] = []
var changed_tile_map:Array[Array] = []
var tile_size:int = 16

var grass_grower:GrassGrower
var keep_placing_tiles:bool = false

func _ready() -> void:
	grass_grower = GrassGrower.new()
	pass

func _process(delta: float) -> void:
	if Engine.get_process_frames() % 2 == 0:
		var results:Dictionary = grass_grower.grow_grass(delta)
		update_food_amount(results["food"])
		terrain_map = results["terrain"]
		changed_tile_map = results["changed"] as Array[Array]
		update_tile_map(results["changed"] as Array[Array])
	if keep_placing_tiles:
		_place_tile()
	pass

func _create_fence_map()->void:
	fence_map= []
	fence_map.resize(world_size.x)
	for x:int in range(world_size.x):
		var col:Array[bool] = []
		col.resize(world_size.y)
		for y:int in range(world_size.y):
			col[y] = false
			pass
		fence_map[x] = col
		pass
	pass

func make_sea()->void:
	var excess:int = 100
	for x:int in range(-excess,world_size.x+excess):
		for y:int in range(-excess,world_size.y+excess):
			terrain_tile_map.set_cell(Vector2i(x,y),0,Vector2i(1,4))
			pass
	pass

func update_food_amount(food:Array[Array])->void:
	food_amount = food
	grass_grower.update_data(terrain_map,food_amount)
	pass

func update_tile_map(changed:Array[Array])->void:
	var tile_changed:bool = false
	# Find list of water tiles
	var water_list:Array[Vector2i] = []
	# Find list of grass tiles
	var grass_list:Array[Vector2i] = []
	# Find list of dirt tiles
	var dirt_list:Array[Vector2i] = []
	for x:int in world_size.x:
		for y: int in world_size.y:
			if changed[x][y] as bool:
				tile_changed = true
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
	if tile_changed:
		tile_placed.emit()
		
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
		match placement_mode:
			TerrainType.GRASS:
				if Shop.buy_grass() if terrain_map[tile_pos.x][tile_pos.y] != TerrainType.GRASS else true:
					terrain_map[tile_pos.x][tile_pos.y] = placement_mode
					terrain_tile_map.set_cells_terrain_connect([Vector2i(tile_pos.x,tile_pos.y)],0,1)
					food_amount[tile_pos.x][tile_pos.y] = 50
					if !grass_place_audio.playing:
						grass_place_audio.play()
			TerrainType.DIRT:
				if Shop.buy_dirt() if\
				 (terrain_map[tile_pos.x][tile_pos.y] != TerrainType.GRASS && terrain_map[tile_pos.x][tile_pos.y] != TerrainType.DIRT)\
				else true :
					terrain_map[tile_pos.x][tile_pos.y] = placement_mode
					terrain_tile_map.set_cells_terrain_connect([Vector2i(tile_pos.x,tile_pos.y)],0,0)
					if !dirt_place_audio.playing:
						dirt_place_audio.play()
			TerrainType.WATER:
				if Shop.buy_water() if terrain_map[tile_pos.x][tile_pos.y] != TerrainType.WATER else true:
					terrain_map[tile_pos.x][tile_pos.y] = placement_mode
					terrain_tile_map.set_cells_terrain_connect([Vector2i(tile_pos.x,tile_pos.y)],0,2)
					fence_map[tile_pos.x][tile_pos.y] = false
					fence_tile_map.erase_cell(Vector2i(tile_pos.x,tile_pos.y))
					if !water_place_audio.playing:
						water_place_audio.play()
			TerrainType.FENCE:
				if terrain_map[tile_pos.x][tile_pos.y] != TerrainType.WATER and Shop.buy_fence() if fence_map[tile_pos.x][tile_pos.y] ==false else true:
					fence_map[tile_pos.x][tile_pos.y] = true
					fence_tile_map.set_cells_terrain_connect([Vector2i(tile_pos.x,tile_pos.y)],0,0,false)
					if !fence_place_audio.playing:
						fence_place_audio.play()
				pass
			TerrainType.REMOVE_FENCE:
				fence_map[tile_pos.x][tile_pos.y] = false
				fence_tile_map.erase_cell(Vector2i(tile_pos.x,tile_pos.y))
				if !fence_place_audio.playing:
					fence_place_audio.play()
				pass
		tile_placed.emit()
		grass_grower.update_data(terrain_map, food_amount)
	pass



func setup_terrain()->void:
	make_sea()
	_create_fence_map()
	grass_grower.update_data(terrain_map,food_amount)
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
	food_amount = []
	for x:int in world_size.x:
		var col:Array[TerrainType] = []
		col.resize(world_size.y)
		var food_Col: Array[float] = []
		for y:int in world_size.y:
			col[y] = TerrainType.WATER
			food_Col.append(0)
			pass
		terrain_map.append(col)
		food_amount.append(food_Col)
	
	@warning_ignore("integer_division")
	var center:Vector2i = Vector2i(world_size/2.0)
	@warning_ignore("integer_division")
	for x:int in range(-initial_island_size/2,initial_island_size/2):
		@warning_ignore("integer_division")
		for y:int in range(-initial_island_size/2,initial_island_size/2):
			terrain_map[center.x+x][center.y+y] = TerrainType.GRASS
			food_amount[center.x+x][center.y+y] = 50
			pass
	
	pass

func get_save_data()->Dictionary:

	return {
		"terrain_map" : terrain_map,
		"fence_map":fence_map,
		"food_amount":food_amount,
		
	}

func apply_save_data(data:Dictionary)->void:
	terrain_map = []#data["terrain_map"] as Array[Array]
	for array:Array in data["terrain_map"]:
		var col:Array[int] = []
		for value:int in array:
			col.append(value)
		terrain_map.append(col)
		
	fence_map = []#data["fence_map"] as  Array
	fence_map.resize(data["fence_map"].size() as int)
	for array:Array in data["fence_map"]:
		fence_map.append(array)
		pass
		
	food_amount = []
	food_amount.resize(data["food_amount"].size()as int)
	for array:Array in data["food_amount"]:
		food_amount.append(array)
		pass
		
	grass_grower.update_data(terrain_map, food_amount)
	pass
