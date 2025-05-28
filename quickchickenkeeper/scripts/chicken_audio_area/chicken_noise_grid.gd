class_name ChickenNoiseGrid extends Node2D

@export var audio_areas:Node2D

var chicken_audio_area_preload:PackedScene = preload("res://scenes/chicken_audio_area/chicken_audio_area.tscn")

var grid_size:Vector2 =Vector2(1600, 1600)
var num_audio_players_per_row:int  = 10
var _new_chicken_positions:PackedVector2Array = []
var _current_chicken_positions:PackedVector2Array = []
var areas:Array[ChickenAudioArea] = []

var chicken_count_thread:Thread = Thread.new()

func _process(delta: float) -> void:
	_calculate_num_players_in_areas()

func _contunually_count_chickens()->void:
	pass

func _calculate_num_players_in_areas()->void:
	_current_chicken_positions = _new_chicken_positions
	var counts:Array[int] = []
	counts.resize(areas.size())
	counts.fill(0)
	for chicken:Vector2 in _current_chicken_positions:
		for area_index:int in range(areas.size()):
			var area:ChickenAudioArea = areas[area_index]
			if chicken.distance_to(area.position)<= area.max_distance:
				counts[area_index] += 1
				break
			pass
		pass
	set_num_players_in_areas(counts)
	pass

func set_num_players_in_areas(chicken_counts:Array[int])->void:
	for i:int in range(areas.size()):
		if chicken_counts[i] < 5:
			areas[i].set_num_players(0)
		elif chicken_counts[i]<10:
			areas[i].set_num_players(1)
		elif chicken_counts[i]<50:
			areas[i].set_num_players(2)
		elif chicken_counts[i]<250:
			areas[i].set_num_players(3)
		elif chicken_counts[i]<750:
			areas[i].set_num_players(4)
		else:
			areas[i].set_num_players(5)

func setup()->void:
	clear_audio_areas_children()
	var spacing:float = grid_size.x/num_audio_players_per_row
	var starting_pos:Vector2 = Vector2(spacing/2, spacing/2)
	for x:int in range(num_audio_players_per_row):
		for y:int in range(int(grid_size.y/spacing)):
			var audio_pos:Vector2 = starting_pos + Vector2(spacing*x, spacing*y)
			var audio_area:ChickenAudioArea = chicken_audio_area_preload.instantiate()
			audio_area.position = audio_pos
			audio_area.max_distance = spacing *1.1
			areas.append(audio_area)
			audio_areas.add_child(audio_area)
			#audio_area.set_num_players(5)
			pass 
		pass
	pass

func set_chicken_positions(positions:PackedVector2Array)->void:
	_new_chicken_positions = positions
	pass

func clear_audio_areas_children()->void:
	var children:Array = audio_areas.get_children()
	areas.clear()
	for child:Node in children:
		audio_areas.remove_child(child)
	pass
