class_name UIOverlay extends Control

@export var fence_button:TextureButton
@export var dirt_button:TextureButton
@export var water_button:TextureButton
@export var grass_button:TextureButton
@export var remove_fence_button:TextureButton
@export var bottom_button_group:Control
@export var money_label:RichTextLabel
@export var sell_item_drop_box:Control
@export var sell_item_drop_box_color:ColorRect
@export var button_toggle_sound_effect:AudioStreamPlayer2D

@export var settings_menu:Control
@export var master_volume: HSlider
@export var chicken_volume: HSlider
@export var ui_volume: HSlider
@export var background_music_volume: HSlider

signal menu_button_pressed
signal save_button_pressed
signal terrain_button_toggled(terrain:TerrainManager.TerrainType)
signal clear_terrain
signal disable_terrain_placement
signal enable_terrain_placement
signal mouse_is_over_settings(over:bool)
signal credits_button_pressed
signal start_new_game

var mouse_over_settings:bool = false

func _ready() -> void:
	#Shop.connect("item_purchased", _update_money_label)
	#Shop.connect("item_sold", _update_money_label)
	Shop.connect("money_changed", _update_money_label)
	resize_ui_for_device()
	_update_money_label()
	_set_volume_sliders_current_value()

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
	settings_menu.visible = !settings_menu.visible
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
	sell_item_drop_box_color.modulate = Color.ALICE_BLUE
	pass # Replace with function body.


func _on_sell_item_drop_box_mouse_exited() -> void:
	Shop.item_over_sell_box = false
	sell_item_drop_box_color.modulate = Color.DARK_BLUE
	pass # Replace with function body.


func _set_volume_sliders_current_value()->void:
	master_volume.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	chicken_volume.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("ChickenSounds")))
	background_music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BackgroundMusic")))
	ui_volume.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("UI_Effects")))
	pass




func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	pass # Replace with function body.


func _on_chicken_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("ChickenSounds"), linear_to_db(value))
	pass # Replace with function body.


func _on_ui_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI_Effects"), linear_to_db(value))
	pass # Replace with function body.


func _on_background_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BackgroundMusic"), linear_to_db(value))
	pass # Replace with function body.


func _on_save_button_pressed() -> void:
	button_toggle_sound_effect.play()
	save_button_pressed.emit()
	pass # Replace with function body.


func _on_settings_menu_mouse_entered() -> void:
	mouse_over_settings = true
	mouse_is_over_settings.emit(true)
	pass # Replace with function body.


func _on_settings_menu_mouse_exited() -> void:
	mouse_over_settings = false
	mouse_is_over_settings.emit(false)
	pass # Replace with function body.

func get_save_data()->Dictionary:
	return {
		"master_volume":master_volume.value,
		"chicken_volume":chicken_volume.value,
		"ui_volume":ui_volume.value,
		"background_music_volume":background_music_volume.value
	}

func apply_save_data(data:Dictionary)->void:
	master_volume.value = data["master_volume"]
	chicken_volume.value = data["chicken_volume"]
	ui_volume.value = data["ui_volume"]
	background_music_volume.value = data["background_music_volume"]
	pass


func _on_quit_button_pressed() -> void:
	button_toggle_sound_effect.play()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if settings_menu.visible == true and event is InputEventMouseButton  and event.pressed and !mouse_over_settings:
		button_toggle_sound_effect.play()
		settings_menu.visible = false
		pass

func _on_save_and_quit_button_pressed() -> void:
	button_toggle_sound_effect.play()
	save_button_pressed.emit()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	pass # Replace with function body.


func _on_menu_button_mouse_entered() -> void:
	mouse_over_settings = true
	pass # Replace with function body.


func _on_menu_button_mouse_exited() -> void:
	mouse_over_settings = false
	pass # Replace with function body.


func _on_credits_button_pressed() -> void:
	credits_button_pressed.emit()
	pass # Replace with function body.


func _on_start_new_game_pressed() -> void:
	start_new_game.emit()
	pass # Replace with function body.
