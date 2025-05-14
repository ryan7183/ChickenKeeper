extends Node2D

@export var terrain_manager:Node2D
@export var chicken_manager:Node2D
@export var camera:Camera2D

var world_size:Vector2 = Vector2(2000,2000)

func _ready() -> void:
	_load_game()
	pass

func _load_game()->void:
	if not FileAccess.file_exists("user://savegame.save"):
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
			continue

		# Get the data from the JSON object.
		var save_data:Dictionary = json.data
		for key:String in save_data:
			match key:
				"terrain_manager":
					terrain_manager.apply_save_data(save_data[key])
				"chicken_keeper":
					chicken_manager.apply_save_data(save_data[key])
				"camera":
					camera.apply_save_data(save_data[key])
	pass

func _save_game()->void:
	var save_file:FileAccess = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var data:Dictionary = {
		"terrain_manager":terrain_manager.get_save_data(),
		"chicken_manager":chicken_manager.get_save_data(),
		"camera":camera.get_save_data(),
	}
	var json_string:String = JSON.stringify(data)
	save_file.store_line(json_string)
	save_file.close()
	pass

func _generate_new_game()->void:
	pass


func _on_ui_menu_button_pressed() -> void:
	_save_game()
	pass # Replace with function body.
