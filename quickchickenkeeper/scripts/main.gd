extends Node2D

@export var gameplay:Node2D

var create_new_game:bool = false

func _process(delta: float) -> void:
	if create_new_game:
		if FileAccess.file_exists("user://chickenkeeper.save"):
			var save_file:DirAccess = DirAccess.open("user://")
			save_file.remove("chickenkeeper.save")
		get_tree().paused = true
		gameplay.free()
		Shop.money = 5000
		var gameplay_packed:PackedScene = load("res://scenes/gameplay.tscn")
		gameplay = gameplay_packed.instantiate()
		gameplay.connect("new_game", _on_gameplay_new_game)
		add_child(gameplay)
		create_new_game = false
		get_tree().paused = false
	
func _on_gameplay_new_game() -> void:
	#var save_file:FileAccess = FileAccess.open("user://hello.txt", FileAccess.WRITE)
	#var json_string:String = "Hello world"
	#save_file.store_line(json_string)
	#save_file.close()
	
	create_new_game = true
	
