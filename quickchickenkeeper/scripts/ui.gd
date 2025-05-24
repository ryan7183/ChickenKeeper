extends Control

@export var fence_button:Button
@export var dirt_button:Button
@export var water_button:Button
@export var grass_button:Button
@export var remove_fence_button:Button
@export var money_label:RichTextLabel
@export var sell_item_drop_box:Control

signal menu_button_pressed
signal terrain_button_toggled(terrain:TerrainManager.TerrainType)
signal clear_terrain
signal disable_terrain_placement
signal enable_terrain_placement

func _ready() -> void:
	Shop.connect("item_purchased", _update_money_label)
	Shop.connect("item_sold", _update_money_label)

func _update_money_label()->void:
	money_label.clear()
	money_label.add_text(str("Money: ", Shop.money))
	pass

func _on_menu_button_pressed() -> void:
	menu_button_pressed.emit()
	pass # Replace with function body.


func _on_fence_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		water_button.button_pressed = false
		dirt_button.button_pressed = false
		grass_button.button_pressed = false
		remove_fence_button.button_pressed =false
		terrain_button_toggled.emit(TerrainManager.TerrainType.FENCE)
	else:
		clear_terrain.emit()
	pass # Replace with function body.


func _on_dirt_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		water_button.button_pressed = false
		fence_button.button_pressed = false
		grass_button.button_pressed = false
		remove_fence_button.button_pressed =false
		terrain_button_toggled.emit(TerrainManager.TerrainType.DIRT)
	else:
		clear_terrain.emit()
	pass # Replace with function body.


func _on_water_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		fence_button.button_pressed = false
		dirt_button.button_pressed = false
		grass_button.button_pressed = false
		remove_fence_button.button_pressed =false
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


func _on_grass_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		fence_button.button_pressed = false
		dirt_button.button_pressed = false
		water_button.button_pressed = false
		remove_fence_button.button_pressed =false
		terrain_button_toggled.emit(TerrainManager.TerrainType.GRASS)
	else:
		clear_terrain.emit()
	pass # Replace with function body.


func _on_remove_fence_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		water_button.button_pressed = false
		dirt_button.button_pressed = false
		grass_button.button_pressed = false
		fence_button.button_pressed = false
		terrain_button_toggled.emit(TerrainManager.TerrainType.REMOVE_FENCE)
	else:
		clear_terrain.emit()
	pass # Replace with function body.

func enable_sell_box()->void:
	sell_item_drop_box.visible = true
	pass

func disable_sell_box()->void:
	sell_item_drop_box.visible = false
	pass


func _on_sell_item_drop_box_mouse_entered() -> void:
	Shop.item_over_sell_box = true
	pass # Replace with function body.


func _on_sell_item_drop_box_mouse_exited() -> void:
	Shop.item_over_sell_box = false
	pass # Replace with function body.
