extends Node2D

var chicken_packed:PackedScene = preload("res://scenes/splash_screen/chicken.tscn")

const max_chickens:int = 1000
var num_chickens:int = 0

func _process(delta: float) -> void:
	if num_chickens < max_chickens:
		spawn_chicken()
	pass


func spawn_chicken()->void:
	var chicken:Node2D = chicken_packed.instantiate()
	chicken.set_chicken_look(randi_range(0,3))
	var screen:Vector2 = get_viewport().size
	chicken.position = Vector2(screen.x+24, randi_range(0,screen.y))
	add_child(chicken)
	num_chickens+=1
	pass
