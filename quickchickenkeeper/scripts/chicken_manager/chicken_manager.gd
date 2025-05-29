class_name ChickenManager extends Node2D

signal item_being_dragged
signal item_being_dropped
signal request_food_amount
signal food_amount_updated(food:Array[Array])
signal chicken_positions_changed(positions:PackedVector2Array)

@export var chicken_multi_mesh:MultiMeshInstance2D
@export var egg_multi_mesh:MultiMeshInstance2D

@export var sold_item_audio_player:AudioStreamPlayer2D

enum Action {EAT, DRINK, WANDER, SIT, FIND_FOOD, FIND_WATER}
enum ChickenType {COMB, NO_COMB}

var draggable_chicken_scene:PackedScene = preload("res://scenes/chicken_manager/draggable_chicken.tscn")
var draggable_egg_scene:PackedScene = preload("res://scenes/chicken_manager/draggable_egg.tscn")

var chicken_positions:Array[Vector2] = []
var chicken_scales:Array[float] = []
var chicken_hunger_satiation:Array[float] = []
var chicken_direction:Array[float] = []
var chicken_animation_frame:Array[int] = []
var chicken_type:Array[int] = []
var chicken_current_action:Array[Action] = []
var chicken_target:Array[Vector2] = []
var chicken_fatigue:Array[float]= []
var chicken_satisfaction_time:Array[float] = []
var chicken_health:Array[float] = []
var chicken_color:Array[int] = [] # A 9 digit integer where each 3 digits is a value

var egg_positions:Array[Vector2] = []
var egg_time_till_hatch:Array[float] = []
var egg_hatchling_color:Array[int] = []
var egg_hatchling_type:Array[ChickenType] = []

const initial_num_chickens:int = 4
var initial_island_size:int = 10
const chicken_sprite_size:int = 24
const egg_sprite_size:int = 32
var tile_size:int = 16
var world_size:Vector2 = Vector2(2000,2000)
var chicken_mover:ChickenMover
var chicken_action_chooser: ChickenActionChooser
var chicken_action_performer:ChickenActionPerformer
var egg_updater:EggUpdater

var terrain:Array[Array] = []
var fences:Array[Array] = []
var dragging_item:bool =false

func _ready() -> void:
	chicken_multi_mesh.multimesh.set_use_custom_data(true)
	chicken_mover = ChickenMover.new()
	chicken_action_chooser = ChickenActionChooser.new()
	chicken_action_performer = ChickenActionPerformer.new()
	egg_updater = EggUpdater.new()
	pass

func spawn_initial_chickens()->void:
	for i in range(initial_num_chickens):
		var center:Vector2 = (world_size*tile_size)/2.0
		var half_island_size:float = (initial_island_size*tile_size)/2.0
		chicken_positions.append(Vector2(randf_range(center.x-half_island_size,center.x+half_island_size),\
		randf_range(center.y-half_island_size,center.y+half_island_size)))
		chicken_scales.append(1.0)
		chicken_hunger_satiation.append(100)
		chicken_direction.append(0)
		chicken_animation_frame.append(0)
		chicken_current_action.append(Action.WANDER)
		chicken_target.append(chicken_positions[i])
		chicken_fatigue.append(100)
		chicken_satisfaction_time.append(20)
		chicken_health.append(100)
		chicken_type.append(randi_range(0,1))
		chicken_color.append(000000000 if randf() <0.5 else 100100100)
		pass
	pass

func _process(delta: float) -> void:
	if (Engine.get_process_frames()+1) % 2 == 0: 
		_update_eggs()
		if chicken_positions.size()>0:
			_determine_actions(delta)
			_move_chickens(delta)
			_request_data_to_perform_chicken_actions()
			_kill_unhealthy_chickens()
			chicken_positions_changed.emit(PackedVector2Array(chicken_positions))
	show_chickens()
	show_eggs()
	pass

func _kill_unhealthy_chickens()->void:
	for i:int in range(chicken_positions.size()-1,-1,-1):
		if chicken_health[i]<=0:
			_remove_chicken(i)
		pass
	pass

func _update_eggs()->void:
	var result:Dictionary = egg_updater.update_eggs(chicken_positions,chicken_satisfaction_time,\
	egg_positions,egg_time_till_hatch, chicken_color, chicken_type, egg_hatchling_color, egg_hatchling_type as Array[int])
	
	chicken_satisfaction_time = result["updated_satisfaction_time"]
	var new_chickens:Array[Dictionary] = result["new_chicken_positions"]
	
	for data:Dictionary in new_chickens:
		_add_chicken({
		"chicken_position":data["position"],
		"chicken_scale":1.0,
		"chicken_hunger_satiation":20,
		"chicken_direction":0,
		"chicken_animation_frame":0,
		"chicken_current_action":Action.WANDER,
		"chicken_target":data["position"],
		"chicken_fatigue":50,
		"chicken_satisfaction":0,
		"chicken_health": 100,
		"chicken_type":data["type"],
		"chicken_color":data["color"],
		})
		pass
	
	egg_positions = result["updated_egg_position_list"]
	egg_time_till_hatch = result["updated_time_tile_hatch"]
	
	var laid_eggs:Array[Dictionary] = result["laid_eggs"] 
	for egg:Dictionary in laid_eggs:
		_add_egg_with_stats(egg)
		pass
	
	pass

func _add_egg(pos:Vector2)->void:
	egg_positions.append(pos)
	egg_time_till_hatch.append(300)
	egg_hatchling_color.append(000000000)
	egg_hatchling_type.append(0)
	pass

func _request_data_to_perform_chicken_actions()->void:
	request_food_amount.emit()
	pass



func _physics_process(delta: float) -> void:
	
	pass

func _determine_actions(delta:float)->void:
	chicken_action_chooser.update_data(chicken_positions ,chicken_hunger_satiation,\
	chicken_fatigue,chicken_target,terrain)
	var result:Dictionary = chicken_action_chooser.decide_chicken_action(delta)
	chicken_target = result["target"]
	chicken_current_action = result["action"]
	pass

func _move_chickens(delta:float)->void:
	chicken_mover.update_data(chicken_positions,chicken_target, terrain,fences)
	var results:Dictionary = chicken_mover.move_chickens(delta)
	chicken_direction = results["direction"]
	chicken_positions = results["position"]

func perform_chicken_actions(food_amount:Array[Array])->void:
	chicken_action_performer.update_data(chicken_positions,food_amount,\
	chicken_hunger_satiation,chicken_fatigue, chicken_current_action,\
	chicken_satisfaction_time, chicken_health)
	var result:Dictionary = chicken_action_performer.perform_chicken_actions()
	food_amount = result["food"]
	chicken_hunger_satiation = result["hunger"]
	chicken_fatigue = result["fatigue"]
	chicken_satisfaction_time = result["satisfaction"]
	chicken_health = result["health"]
	food_amount_updated.emit(food_amount)
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
	if chicken_multi_mesh.multimesh.instance_count != chicken_positions.size():
		chicken_multi_mesh.multimesh.instance_count=chicken_positions.size()
	for i:int in range(chicken_positions.size()):
		if chicken_current_action[i] != ChickenManager.Action.SIT:
			var dir:Vector2 = _determin_chicken_direction_frame(i)
			
			#var pos:Transform2D = Transform2D(0.0,Vector2(dir.x*chicken_scales[i],chicken_scales[i]),0.0,chicken_positions[i])
			#chicken_multi_mesh.multimesh.set_instance_transform_2d(i, pos)
			_set_chicken_multimesh_instance_transform(dir,i)
			
			
			var animation_x_index: int = chicken_animation_frame[i] + (chicken_type[i]*8)
			chicken_multi_mesh.multimesh.set_instance_custom_data(i,Color( animation_x_index, dir.y,chicken_color[i],0))
			if Engine.get_frames_drawn()%8 == 0:
				chicken_animation_frame[i] = _determine_next_chicken_animation_frame(i)
		pass
	pass

func _set_chicken_multimesh_instance_transform(dir:Vector2, i:int)->void:
	var pos:Transform2D = Transform2D(0.0,Vector2(dir.x*chicken_scales[i],chicken_scales[i]),0.0,chicken_positions[i])
	chicken_multi_mesh.multimesh.set_instance_transform_2d(i, pos)
	pass


func _determine_next_chicken_animation_frame(chicken_index:int)->int:
	var frame:int = 0
	var current_frame:int = chicken_animation_frame[chicken_index]
	match chicken_current_action[chicken_index]:
		Action.SIT:
			frame = 8
			pass
		Action.EAT:
			if current_frame == 0:
				frame = 1
			elif current_frame == 1:
				frame = 2
			else:
				frame = 0
			pass
		Action.WANDER, Action.FIND_FOOD:
			if current_frame == 3:
				frame = 4
			elif current_frame == 4:
				frame = 5
			elif current_frame == 6:
				frame = 7
			else:
				frame = 3
			pass
			
	return frame#(chicken_animation_frame[chicken_index]+1)%8

func _determin_chicken_direction_frame(chicken_index:int)->Vector2:
	var frame_dir:Vector2 = Vector2(0,0)
	var angle:float = rad_to_deg(chicken_positions[chicken_index].angle_to_point(chicken_target[chicken_index]))
	
	if angle>=-90 and angle <=0 || angle>=0 and angle<=90:
		frame_dir.x = -1
	else:
		frame_dir.x = 1
	
	if angle>60 and angle<120:
		frame_dir.y = 1
	elif angle<-60 and angle>-120:
		frame_dir.y = 2
		pass
	return frame_dir

func show_eggs()->void:
	egg_multi_mesh.multimesh.instance_count=egg_positions.size()
	for i:int in range(egg_positions.size()):
		var pos:Transform2D = Transform2D(0.0,Vector2(0.5,0.5),0.0,egg_positions[i])
		egg_multi_mesh.multimesh.set_instance_transform_2d(i, pos)
		pass
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PickUpChicken") and !dragging_item: 
		var mouse_pos:Vector2 = get_global_mouse_position()
		var chicken_data:Dictionary = _remove_chicken_if_mouse_over(mouse_pos)
		if chicken_data.has("chicken_position"):
			var draggable_instance:DraggableChicken = draggable_chicken_scene.instantiate()
			draggable_instance.scale = Vector2(2.0,2.0)
			draggable_instance.tile_size = tile_size
			draggable_instance.world_size = world_size
			draggable_instance.dropped.connect(_on_draggable_chicken_drop.bind(chicken_data))
			add_child(draggable_instance)
			item_being_dragged.emit()
			pass
	
	if event.is_action_pressed("PickUpEgg") and !dragging_item: 
		var mouse_pos:Vector2 = get_global_mouse_position()
		var egg_data:Dictionary = _remove_egg_if_mouse_over(mouse_pos)
		if egg_data.has("egg_position"):
			var draggable_instance:DraggableEgg = draggable_egg_scene.instantiate()
			draggable_instance.scale = Vector2(2.0,2.0)
			draggable_instance.tile_size = tile_size
			draggable_instance.world_size = world_size
			draggable_instance.dropped.connect(_on_draggable_egg_drop.bind(egg_data))
			add_child(draggable_instance)
			item_being_dragged.emit()
			pass
	
		pass
	pass

func _on_draggable_chicken_drop(pos:Vector2,data:Dictionary)->void:
	dragging_item = false
	if !Shop.item_over_sell_box:
		data["chicken_position"] = pos
		_add_chicken(data)
	else:
		Shop.sell_chicken()
		sold_item_audio_player.play()
		pass
	item_being_dropped.emit()
	pass

func _on_draggable_egg_drop(pos:Vector2,data:Dictionary)->void:
	dragging_item = false
	if !Shop.item_over_sell_box:
		data["egg_position"] = pos
		_add_egg_with_stats(data)
	else:
		Shop.sell_egg()
		sold_item_audio_player.play()
	
	item_being_dropped.emit()
	pass

func _remove_chicken_if_mouse_over(pos:Vector2)->Dictionary:
	for i:int in range(chicken_positions.size()):
		var chicken_pos:Vector2 = chicken_positions[i]
		var chicken_size:float = chicken_scales[i]*chicken_sprite_size
		chicken_pos += Vector2(chicken_size/2.0, chicken_size/2.0)
		if chicken_pos.distance_to(pos)<chicken_size:#/2.0:
			dragging_item = true
			return _remove_chicken(i)
	return {}

func _remove_egg_if_mouse_over(pos:Vector2)->Dictionary:
	for i:int in range(egg_positions.size()):
		var egg_pos:Vector2 = egg_positions[i]
		egg_pos += Vector2(egg_sprite_size/2.0, egg_sprite_size/2.0)
		if egg_pos.distance_to(pos)<egg_sprite_size:#/2.0:
			dragging_item = true
			return _remove_egg(i)
	return {}

func _remove_egg(i:int)->Dictionary:
	var data:Dictionary = {
		"egg_position":egg_positions[i],
		"egg_time_till_hatch":egg_time_till_hatch[i],
		"egg_hatchling_color":egg_hatchling_color[i],
		"egg_hatchling_type":egg_hatchling_type[i],
	}
	
	egg_positions.remove_at(i)
	egg_time_till_hatch.remove_at(i)
	egg_hatchling_color.remove_at(i)
	egg_hatchling_type.remove_at(i)
	return data

func _add_egg_with_stats(data:Dictionary)->void:
	egg_positions.append(data["egg_position"])
	egg_time_till_hatch.append(data["egg_time_till_hatch"])
	egg_hatchling_color.append(data["egg_hatchling_color"])
	egg_hatchling_type.append(data["egg_hatchling_type"])
	pass

func _add_chicken(data:Dictionary)->void:
	chicken_positions.append(data["chicken_position"])
	chicken_scales.append(data["chicken_scale"])
	chicken_hunger_satiation.append(data["chicken_hunger_satiation"])
	chicken_direction.append(data["chicken_direction"])
	chicken_animation_frame.append(data["chicken_animation_frame"])
	chicken_current_action.append(data["chicken_current_action"] as Action)
	chicken_target.append(data["chicken_target"])
	chicken_fatigue.append(data["chicken_fatigue"])
	chicken_satisfaction_time.append(data["chicken_satisfaction"])
	chicken_health.append(data["chicken_health"])
	chicken_type.append(data["chicken_type"])
	chicken_color.append(data["chicken_color"])
	pass

func _remove_chicken(i:int)->Dictionary:
	var data:Dictionary = {
		"chicken_position":chicken_positions[i],
		"chicken_scale":chicken_scales[i],
		"chicken_hunger_satiation":chicken_hunger_satiation[i],
		"chicken_direction":chicken_direction[i],
		"chicken_animation_frame":chicken_animation_frame[i],
		"chicken_current_action":chicken_current_action[i],
		"chicken_target":chicken_target[i],
		"chicken_fatigue":chicken_fatigue[i],
		"chicken_satisfaction":chicken_satisfaction_time[i],
		"chicken_health":chicken_health[i],
		"chicken_type":chicken_type[i],
		"chicken_color":chicken_color[i],
	}
	chicken_positions.remove_at(i)
	chicken_scales.remove_at(i)
	chicken_hunger_satiation.remove_at(i)
	chicken_direction.remove_at(i)
	chicken_animation_frame.remove_at(i)
	chicken_current_action.remove_at(i)
	chicken_target.remove_at(i)
	chicken_fatigue.remove_at(i)
	chicken_satisfaction_time.remove_at(i)
	chicken_health.remove_at(i)
	chicken_type.remove_at(i)
	chicken_color.remove_at(i)
	return data
