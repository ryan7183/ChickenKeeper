class_name ChickenActionChooser extends Node



var packed_chicken_positions:PackedVector2Array = []
var packed_chicken_hunger_satiation: PackedFloat32Array = []
var packed_chicken_fatigue:PackedFloat32Array= []
var packed_chicken_target:PackedVector2Array = []
var packed_terrain: PackedInt32Array = []
var terrain_width:int

var shader:RID
var rendering_device :RenderingDevice = RenderingServer.create_local_rendering_device()
var pos_in_buffer:RID
var pos_out_buffer:RID
var target_in_buffer:RID
var terrain_in_buffer:RID
var tile_size:int

var target_output:Array[Vector2]= []
var action_output:Array[ChickenManager.Action] = []

func update_data(positions:Array[Vector2], hunger_satiation:Array[float], chicken_fatigue:Array[float], targets:Array[Vector2], terrain:Array[Array])->void:
	packed_chicken_positions = PackedVector2Array(positions)
	packed_chicken_hunger_satiation = PackedFloat32Array(hunger_satiation)
	packed_chicken_fatigue = PackedFloat32Array(chicken_fatigue)
	packed_chicken_target = PackedVector2Array(targets)
	terrain_width = terrain.size()
	packed_terrain = _terrain_to_packed(terrain)
	pass

func _terrain_to_packed(terrain:Array[Array])->PackedInt32Array:
	var new_arr:Array[int]=[]
	for arr:Array in terrain:
		new_arr.append_array(arr)
	return PackedInt32Array(new_arr)

func move_chickens(delta:float)->Dictionary:
	if !shader.is_valid():
		_build_shader()
	
	_run_shader(delta)
	_retrieve_shader_data()
	
	return {}

func _retrieve_shader_data()->void:
		
		
	pass

func _byte_array_to_vec2_array(bytes:PackedByteArray)->Array[Vector2]:
	var decoded :Array = bytes.to_float32_array()
	var arr: Array[Vector2] = []
	
	for i:int in range(1,decoded.size(),2):
		arr.append(Vector2(decoded[i-1],decoded[i]))
		pass
	
	return arr

func _run_shader(delta:float)->void:
	
	var parameters:PackedByteArray = _make_movement_shader_parameters(delta)
	
	
	var movement_uniform_set :RID= rendering_device.uniform_set_create([
		], shader, 0)
	
	# Create a compute pipeline
	var pipeline :RID = rendering_device.compute_pipeline_create(shader)
	var compute_list :int= rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rendering_device.compute_list_bind_uniform_set(compute_list, movement_uniform_set, 0)
	rendering_device.compute_list_set_push_constant(compute_list, parameters, parameters.size())
	var work_group_size:int = packed_chicken_positions.size()/100 + packed_chicken_positions.size()%100
	rendering_device.compute_list_dispatch(compute_list,  work_group_size, 1, 1)
	rendering_device.compute_list_end()
	
	if movement_uniform_set.is_valid():
		rendering_device.free_rid(movement_uniform_set)
	if pipeline.is_valid():
		rendering_device.free_rid(pipeline)
	
	pass

func _make_movement_shader_parameters(delta:float)->PackedByteArray:
	var parameters :PackedByteArray = PackedByteArray()
	parameters.resize(16)
	parameters.encode_float(0, delta)
	parameters.encode_u32(4,terrain_width)
	return parameters

func _build_shader()->void:
	var shader_file:Resource = load("res://scripts/chicken_manager/chicken_action_chooser.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rendering_device.shader_create_from_spirv(shader_spirv)
	pass
