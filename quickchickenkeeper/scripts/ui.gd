extends Control

@export var fence_button:Button
@export var dirt_button:Button
@export var water_button:Button

signal menu_button_pressed
signal fence_button_toggled(toggled_on:bool)
signal water_button_toggled(toggled_on:bool)
signal dirt_button_toggled(toggled_on:bool)

func _on_menu_button_pressed() -> void:
	menu_button_pressed.emit()
	pass # Replace with function body.


func _on_fence_button_toggled(toggled_on: bool) -> void:
	water_button.button_pressed = false
	dirt_button.button_pressed = false
	fence_button_toggled.emit(toggled_on)
	pass # Replace with function body.


func _on_dirt_button_toggled(toggled_on: bool) -> void:
	water_button.button_pressed = false
	fence_button.button_pressed = false
	dirt_button_toggled.emit(toggled_on)
	pass # Replace with function body.


func _on_water_button_toggled(toggled_on: bool) -> void:
	fence_button.button_pressed = false
	dirt_button.button_pressed = false
	water_button_toggled.emit(toggled_on)
	pass # Replace with function body.
