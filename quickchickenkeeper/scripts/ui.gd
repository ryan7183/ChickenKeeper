extends Control

@export var fence_button:TextureButton
@export var dirt_button:TextureButton
@export var water_button:TextureButton
@export var grass_button:TextureButton
@export var remove_fence_button:TextureButton
@export var bottom_button_group:Control
@export var money_label:RichTextLabel
@export var sell_item_drop_box:Control
@export var button_toggle_sound_effect:AudioStreamPlayer2D

signal menu_button_pressed
signal terrain_button_toggled(terrain:TerrainManager.TerrainType)
signal clear_terrain
signal disable_terrain_placement
signal enable_terrain_placement

func _ready() -> void:
	#Shop.connect("item_purchased", _update_money_label)
	#Shop.connect("item_sold", _update_money_label)
	Shop.connect("money_changed", _update_money_label)
	resize_ui_for_device()
	_update_money_label()

func resize_ui_for_device()->void:
	var os_name:String = OS.get_name()
	var button_size:Vector2 = Vector2(64,64)
	match os_name:
		"Windows","macOS","Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			button_size = Vector2(64, 64)
		"Android","iOS","Web":
			button_size = Vector2(128, 128)
			fence_button.texture_hover = null
			dirt_button.texture_hover = null
			water_button.texture_hover = null
			grass_button.texture_hover = null
			remove_fence_button.texture_hover = null
	fence_button.custom_minimum_size = button_size
	dirt_button.custom_minimum_size = button_size
	water_button.custom_minimum_size = button_size
	grass_button.custom_minimum_size = button_size
	remove_fence_button.custom_minimum_size = button_size
	bottom_button_group.custom_minimum_size.y= button_size.y
	pass

func _update_money_label()->void:
	money_label.clear()
	money_label.add_text(str("Money: ", Shop.money))
	pass

func _on_menu_button_pressed() -> void:
	button_toggle_sound_effect.play()
	menu_button_pressed.emit()
	pass # Replace with function body.


func _on_fence_button_toggled(toggled_on: bool) -> void:
	button_toggle_sound_effect.play()
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
	button_toggle_sound_effect.play()
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
	button_toggle_sound_effect.play()
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
	button_toggle_sound_effect.play()
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
	button_toggle_sound_effect.play()
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
