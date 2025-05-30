extends Control

signal back_button_pressed

func _on_button_pressed() -> void:
	back_button_pressed.emit()
	pass # Replace with function body.
