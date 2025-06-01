extends Control

const main_scene_path:String = "res://scenes/main.tscn"

var min_wait_time:float = 5

var main_scene:PackedScene
var load_done:bool = false

var main_scene_mutex:Mutex = Mutex.new()
var load_done_mutex:Mutex = Mutex.new()
var task_id:int

func _ready() -> void:
	task_id = WorkerThreadPool.add_task(load_scene, true)
	pass

func load_scene()->void:
	main_scene_mutex.lock()
	main_scene = load("res://scenes/main.tscn")
	main_scene_mutex.unlock()
	
	load_done_mutex.lock()
	load_done = true
	load_done_mutex.unlock()
	
	pass

func _process(delta: float) -> void:
	if min_wait_time <=0 and load_done_mutex.try_lock():
		if load_done:
			get_tree().change_scene_to_packed(main_scene)
		load_done_mutex.unlock()
	
	min_wait_time -= delta
	pass
