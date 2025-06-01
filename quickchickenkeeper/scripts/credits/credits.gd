extends Control

signal back_button_pressed

func _on_button_pressed() -> void:
	back_button_pressed.emit()
	pass # Replace with function body.


func _on_texture_rect_pressed() -> void:
	var site:String = "https://godotengine.org/license/"
	OS.shell_open(site)
	pass # Replace with function body.
