class_name Chicken extends Node2D

@export var chicken_multi_mesh:MultiMeshInstance2D
@export var egg_multi_mesh:MultiMeshInstance2D

var chicken_positions:Array[Vector2] = []
var egg_positions:Array[Vector2] = []
var num_chickens:int = 5

func _ready() -> void:
	chicken_multi_mesh.multimesh.set_use_custom_data(true)
	for i in range(num_chickens):
		chicken_positions.append(Vector2(randf_range(0,1000),randf_range(0,1000)))
		pass
	show_chickens()
	show_eggs()
	pass

func show_chickens()->void:
	chicken_multi_mesh.multimesh.instance_count=num_chickens
	for i in range(num_chickens):
		var pos:Transform2D = Transform2D(0.0,Vector2(2.0,2.0),0.0,chicken_positions[i])
		chicken_multi_mesh.multimesh.set_instance_transform_2d(i, pos)
		chicken_multi_mesh.multimesh.set_instance_custom_data(i,Color( 0, 0,0,0))
		pass
	pass

func show_eggs()->void:
	egg_multi_mesh.multimesh.instance_count=num_chickens
	for i in range(5):
		var pos:Transform2D = Transform2D(0.0,Vector2(0.5,0.5),0.0,Vector2(randf_range(0,500),randf_range(0,500)))
		egg_multi_mesh.multimesh.set_instance_transform_2d(i, pos)
		pass
	pass
