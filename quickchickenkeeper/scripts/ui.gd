extends Control

@export var fence_button:Button
@export var dirt_button:Button
@export var water_button:Button

signal menu_button_pressed
signal terrain_button_toggled(terrain:TerrainManager.TerrainType)
signal clear_terrain
signal disable_terrain_placement
signal enable_terrain_placement
func _on_menu_button_pressed() -> void:
	menu_button_pressed.emit()
	pass # Replace with function body.


func _on_fence_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		water_button.button_pressed = false
		dirt_button.button_pressed = false
		terrain_button_toggled.emit(TerrainManager.TerrainType.FENCE)
	else:
		clear_terrain.emit()
	pass # Replace with function body.


func _on_dirt_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		water_button.button_pressed = false
		fence_button.button_pressed = false
		terrain_button_toggled.emit(TerrainManager.TerrainType.DIRT)
	else:
		clear_terrain.emit()
	pass # Replace with function body.


func _on_water_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		fence_button.button_pressed = false
		dirt_button.button_pressed = false
		terrain_button_toggled.emit(TerrainManager.TerrainType.WATER)
	else:
		clear_terrain.emit()
	pass # Replace with function body.

func _on_disable_tile_placement()->void:
	disable_terrain_placement.emit()
	pass

func _on_enable_tile_placement()->void:
	enable_terrain_placement.emit()
	pass
