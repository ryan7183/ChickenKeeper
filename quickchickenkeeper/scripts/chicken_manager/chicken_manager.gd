class_name ChickenManager extends Node2D

signal item_being_dragged
signal item_being_dropped

@export var chicken_multi_mesh:MultiMeshInstance2D
@export var egg_multi_mesh:MultiMeshInstance2D

enum Action {EAT, WANDER, WALK_TO_TARGET, SIT}
var draggable_chicken_scene:PackedScene = preload("res://scenes/chicken_manager/draggable_chicken.tscn")

var chicken_positions:Array[Vector2] = []
var chicken_scales:Array[float] = []
var chicken_hunger_satiation:Array[float] = []
var chicken_direction:Array[int] = []
var chicken_animation_frame:Array[int] = []
var chicken_type:Array[int] = []
var chicken_current_action:Array[Action] = []
var egg_positions:Array[Vector2] = []
const initial_num_chickens:int = 2
var initial_island_size:int = 10
const chicken_sprite_size:int = 24
var tile_size:int = 16
var world_size:Vector2 = Vector2(2000,2000)

func _ready() -> void:
	chicken_multi_mesh.multimesh.set_use_custom_data(true)
	pass

func spawn_initial_chickens()->void:
	for i in range(initial_num_chickens):
		var center:Vector2 = (world_size*tile_size)/2.0
		var half_island_size:float = (initial_island_size*tile_size)/2.0
		chicken_positions.append(Vector2(randf_range(center.x-half_island_size,center.x+half_island_size),\
		randf_range(center.y-half_island_size,center.y+half_island_size)))
		chicken_scales.append(1.0)
		chicken_hunger_satiation.append(50)
		chicken_direction.append(0)
		chicken_animation_frame.append(0)
		chicken_type.append(0)
		chicken_current_action.append(Action.WANDER)
		pass
	pass

func _process(_delta: float) -> void:
	show_chickens()
	show_eggs()
	pass

func get_save_data()->Dictionary:
	return {
		"chicken_positions": chicken_positions,
		"chicken_scales": chicken_scales,
		"egg_positions":egg_positions,
	}

func apply_save_data(data:Dictionary)->void:
	for i:int in data["chicken_positions"].size():
		var vector:Vector2 = str_to_var("Vector2" + (data["chicken_positions"][i]) as String)
		var chicken_scale:float = data["chicken_scales"][i]
		
		chicken_scales.append(chicken_scale)
		chicken_positions.append(vector)
		pass
	
	egg_positions.assign(data["egg_positions"] as Array)
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
	egg_multi_mesh.multimesh.instance_count=initial_island_size
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
			item_being_dragged.emit()
			pass
	
	
		pass
	pass

func _on_draggable_chicken_drop(pos:Vector2,data:Dictionary)->void:
	data["chicken_position"] = pos
	_add_chicken(data)
	item_being_dropped.emit()
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
	chicken_hunger_satiation.remove_at(i)
	chicken_direction.remove_at(i)
	chicken_animation_frame.remove_at(i)
	chicken_type.remove_at(i)
	chicken_current_action.remove_at(i)
	return data
