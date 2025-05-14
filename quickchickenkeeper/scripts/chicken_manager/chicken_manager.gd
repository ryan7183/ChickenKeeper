class_name ChickenManager extends Node2D

@export var chicken_multi_mesh:MultiMeshInstance2D
@export var egg_multi_mesh:MultiMeshInstance2D

var draggable_chicken_scene:PackedScene = preload("res://scenes/chicken_manager/draggable_chicken.tscn")

var chicken_positions:Array[Vector2] = []
var chicken_scales:Array[float] = []
var egg_positions:Array[Vector2] = []
var num_chickens:int = 10
var chicken_sprite_size:int = 24

var world_size:Vector2 = Vector2(2000,2000)

func _ready() -> void:
	chicken_multi_mesh.multimesh.set_use_custom_data(true)
	for i in range(num_chickens):
		chicken_positions.append(Vector2(randf_range(0,1000),randf_range(0,1000)))
		chicken_scales.append(1.0)
		pass
	show_eggs()
	show_chickens()
	pass

func _process(_delta: float) -> void:
	show_chickens()
	show_eggs()
	pass

func get_save_data()->Dictionary:
	return {}

func apply_save_data(data:Dictionary)->void:
	pass

func show_chickens()->void:
	chicken_multi_mesh.multimesh.instance_count=chicken_positions.size()
	for i:int in range(chicken_positions.size()):
		var pos:Transform2D = Transform2D(0.0,Vector2(chicken_scales[i],chicken_scales[i]),0.0,chicken_positions[i])
		chicken_multi_mesh.multimesh.set_instance_transform_2d(i, pos)
		chicken_multi_mesh.multimesh.set_instance_custom_data(i,Color( 0, 0,0,0))
		pass
	pass

func show_eggs()->void:
	egg_multi_mesh.multimesh.instance_count=num_chickens
	for i:int in range(egg_positions.size()):
		var pos:Transform2D = Transform2D(0.0,Vector2(0.5,0.5),0.0,egg_positions[i])
		egg_multi_mesh.multimesh.set_instance_transform_2d(i, pos)
		pass
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PickUpChicken"): 
		var mouse_pos:Vector2 = get_global_mouse_position()
		var chicken_data:Dictionary = _remove_chicken_if_mouse_over(mouse_pos)
		if chicken_data.has("chicken_position"):
			var draggable_instance:DraggableChicken = draggable_chicken_scene.instantiate()
			draggable_instance.scale = Vector2(2.0,2.0)
			draggable_instance.dropped.connect(_on_draggable_chicken_drop.bind(chicken_data))
			add_child(draggable_instance)
			pass
	
	
		pass
	pass

func _on_draggable_chicken_drop(pos:Vector2,data:Dictionary)->void:
	data["chicken_position"] = pos
	_add_chicken(data)
	pass

func _remove_chicken_if_mouse_over(pos:Vector2)->Dictionary:
	for i:int in range(chicken_positions.size()):
		var chicken_pos:Vector2 = chicken_positions[i]
		var chicken_size:float = chicken_scales[i]*chicken_sprite_size
		chicken_pos += Vector2(chicken_size/2.0, chicken_size/2.0)
		if chicken_pos.distance_to(pos)<chicken_size:#/2.0:
			return _remove_chicken(i)
	return {}

func _add_chicken(data:Dictionary)->void:
	chicken_positions.append(data["chicken_position"])
	chicken_scales.append(data["chicken_scale"])
	pass

func _remove_chicken(i:int)->Dictionary:
	var data:Dictionary = {
		"chicken_position":chicken_positions[i],
		"chicken_scale":chicken_scales[i]
	}
	chicken_positions.remove_at(i)
	chicken_scales.remove_at(i)
	return data
