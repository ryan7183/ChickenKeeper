extends Node2D

@export var terrain_manager:TerrainManager
@export var chicken_manager:ChickenManager
@export var camera:Camera
@export var ui_overlay:Control
@export var chicken_noise_grid:ChickenNoiseGrid

const world_size:Vector2 = Vector2(100,100)
const tile_size:int = 16
const initial_island_size:int = 10

func _ready() -> void:
	
	terrain_manager.world_size = world_size
	chicken_manager.world_size = world_size
	camera.world_size = world_size
	chicken_manager.initial_island_size = initial_island_size
	terrain_manager.tile_size= 16
	chicken_manager.tile_size= 16
	_load_game()
	terrain_manager.setup_terrain()
	chicken_manager.terrain = terrain_manager.terrain_map
	chicken_manager.fences = terrain_manager.fence_map
	
	chicken_noise_grid.grid_size = world_size * tile_size
	chicken_noise_grid.setup()
	pass

func _load_game()->void:
	var success:bool = true
	if not FileAccess.file_exists("user://savegame.save"):
		_generate_new_game()
		return # Error! We don't have a save to load.
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file:FileAccess = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string:String = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json:JSON = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result:Error = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			success=false
			continue

		# Get the data from the JSON object.
		var save_data:Dictionary = json.data
		for key:String in save_data:
			match key:
				"main":
					pass
				"terrain_manager":
					terrain_manager.apply_save_data(save_data[key] as Dictionary)
				"chicken_manager":
					chicken_manager.apply_save_data(save_data[key] as Dictionary)
				"camera":
					camera.apply_save_data(save_data[key] as Dictionary)
				"shop":
					Shop.apply_save_data(save_data["shop"])
	if !success:
		_generate_new_game()
	pass

func _save_game()->void:
	var save_file:FileAccess = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var data:Dictionary = {
		"main": get_save_data(),
		"terrain_manager":terrain_manager.get_save_data(),
		"chicken_manager":chicken_manager.get_save_data(),
		"camera":camera.get_save_data(),
		"shop":Shop.get_save_data(),
	}
	var json_string:String = JSON.stringify(data)
	save_file.store_line(json_string)
	save_file.close()
	pass

func get_save_data()->Dictionary:
	return {
	}

func _generate_new_game()->void:
	terrain_manager.world_size = world_size
	terrain_manager.generate_initial_island()
	chicken_manager.spawn_initial_chickens()
	pass


func _on_ui_menu_button_pressed() -> void:
	
	pass # Replace with function body.


func _on_chicken_manager_item_being_dragged() -> void:
	terrain_manager.disable_tile_placement = true
	ui_overlay.enable_sell_box()
	pass # Replace with function body.


func _on_chicken_manager_item_being_dropped() -> void:
	terrain_manager.disable_tile_placement = false
	ui_overlay.disable_sell_box()
	pass # Replace with function body.


func _on_ui_terrain_button_toggled(terrain: TerrainManager.TerrainType) -> void:
	terrain_manager.placement_mode = terrain
	pass # Replace with function body.


func _on_ui_clear_terrain() -> void:
	terrain_manager.placement_mode = TerrainManager.TerrainType.NOTHING
	pass # Replace with function body.


func _on_ui_disable_terrain_placement() -> void:
	terrain_manager.disable_tile_placement = true
	pass # Replace with function body.


func _on_ui_enable_terrain_placement() -> void:
	terrain_manager.disable_tile_placement = false
	pass # Replace with function body.


func _on_terrain_manager_tile_placed() -> void:
	chicken_manager.terrain = terrain_manager.terrain_map
	chicken_manager.fences = terrain_manager.fence_map
	pass # Replace with function body.


func _on_chicken_manager_request_food_amount() -> void:
	chicken_manager.perform_chicken_actions(terrain_manager.food_amount)
	pass # Replace with function body.


func _on_chicken_manager_food_amount_updated(food: Array[Array]) -> void:
	terrain_manager.update_food_amount(food)
	pass # Replace with function body.


func _on_chicken_manager_chicken_positions_changed(positions: PackedVector2Array) -> void:
	chicken_noise_grid.set_chicken_positions(positions)
	pass # Replace with function body.


func _on_ui_save_button_pressed() -> void:
	_save_game()
	pass # Replace with function body.


func _on_ui_mouse_is_over_settings(over: bool) -> void:
	chicken_manager.disable_dragging_items = over
	pass # Replace with function body.
