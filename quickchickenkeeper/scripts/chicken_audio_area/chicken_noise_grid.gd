class_name ChickenNoiseGrid extends Node2D

@export var audio_areas:Node2D

var chicken_audio_area_preload:PackedScene = preload("res://scenes/chicken_audio_area/chicken_audio_area.tscn")

var grid_size:Vector2 =Vector2(1600, 1600)
var num_audio_players_per_row:int  = 10
var _new_chicken_positions:PackedVector2Array = []
var new_chicken_positions_mutex:Mutex = Mutex.new()
var _current_chicken_positions:PackedVector2Array = []
var areas:Array[ChickenAudioArea] = []

var areas_positions:Array[Vector2] = []
var areas_positions_mutex:Mutex = Mutex.new()
var max_distance:float = 2000
var max_distance_mutex:Mutex = Mutex.new()
var chicken_counts:Array[int] = []
var chicken_counts_mutex:Mutex = Mutex.new()
var chicken_count_thread:Thread = Thread.new()
var start_count:Semaphore = Semaphore.new()
var _current_chicken_positions_mutex:Mutex = Mutex.new()
var exit_count_thread:bool = false
var exit_count_thread_mutex:Mutex = Mutex.new()
var new_chicken_counts:bool =false
var new_chicken_counts_mutex:Mutex =Mutex.new()

func _ready() -> void:
	
	pass

func _process(delta: float) -> void:
	new_chicken_counts_mutex.lock()
	if new_chicken_counts:
		new_chicken_counts = false
		chicken_counts_mutex.lock()
		set_num_players_in_areas(chicken_counts)
		chicken_counts_mutex.unlock()
	new_chicken_counts_mutex.unlock()

func _exit_tree() -> void:
	
	# End thread on exit
	exit_count_thread_mutex.lock()
	exit_count_thread = true
	exit_count_thread_mutex.unlock()
	start_count.post()
	chicken_count_thread.wait_to_finish()
	pass

func _contunually_count_chickens()->void:
	
	while true:
		start_count.wait()
		
		exit_count_thread_mutex.lock()
		if exit_count_thread:
			break
		exit_count_thread_mutex.unlock()
		
		_calculate_num_players_in_areas()
		pass
	pass

func _calculate_num_players_in_areas()->void:
	_current_chicken_positions_mutex.lock()
	
	new_chicken_positions_mutex.lock()
	_current_chicken_positions = _new_chicken_positions.duplicate()
	new_chicken_positions_mutex.unlock()
	
	var counts:Array[int] = []
	counts.resize(areas.size())
	counts.fill(0)
	areas_positions_mutex.lock()
	max_distance_mutex.lock()
	for chicken:Vector2 in _current_chicken_positions:
		for area_index:int in range(areas.size()):
			var area:ChickenAudioArea = areas[area_index]
			if chicken.distance_to(areas_positions[area_index])<= max_distance:
				counts[area_index] += 1
				break
			pass
		pass
	areas_positions_mutex.unlock()
	max_distance_mutex.unlock()
	_current_chicken_positions_mutex.unlock()
	new_chicken_counts_mutex.lock()
	new_chicken_counts = true
	chicken_counts = counts
	new_chicken_counts_mutex.unlock()

func set_num_players_in_areas(counts:Array[int])->void:
	for i:int in range(areas.size()):
		if counts[i] < 5:
			areas[i].set_num_players(0)
		elif counts[i]<10:
			areas[i].set_num_players(1)
		elif counts[i]<50:
			areas[i].set_num_players(2)
		elif counts[i]<250:
			areas[i].set_num_players(3)
		elif counts[i]<750:
			areas[i].set_num_players(4)
		else:
			areas[i].set_num_players(5)

func setup()->void:
	clear_audio_areas_children()
	var spacing:float = grid_size.x/num_audio_players_per_row
	max_distance = spacing * 1.5
	var starting_pos:Vector2 = Vector2(spacing/2, spacing/2)
	areas_positions_mutex.lock()
	max_distance_mutex.lock()
	for x:int in range(num_audio_players_per_row):
		for y:int in range(int(grid_size.y/spacing)):
			var audio_pos:Vector2 = starting_pos + Vector2(spacing*x, spacing*y)
			var audio_area:ChickenAudioArea = chicken_audio_area_preload.instantiate()
			audio_area.position = audio_pos
			audio_area.max_distance = max_distance
			areas.append(audio_area)
			areas_positions.append(Vector2(audio_pos.x, audio_pos.y))
			audio_areas.add_child(audio_area)
			#audio_area.set_num_players(5)
			pass 
		pass
	areas_positions_mutex.unlock()
	max_distance_mutex.unlock()
	chicken_count_thread.start(_contunually_count_chickens)
	pass

func set_chicken_positions(positions:PackedVector2Array)->void:
	if new_chicken_positions_mutex.try_lock():
		_new_chicken_positions = positions
		new_chicken_positions_mutex.unlock()
		start_count.post()
	pass

func clear_audio_areas_children()->void:
	var children:Array = audio_areas.get_children()
	areas.clear()
	for child:Node in children:
		audio_areas.remove_child(child)
	pass
