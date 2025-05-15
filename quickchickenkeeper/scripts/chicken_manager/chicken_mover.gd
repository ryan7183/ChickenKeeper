class_name ChickenMover extends Resource


var positions_array:PackedVector2Array = []
var targets_array:PackedVector2Array = []
var position_output:Array[Vector2] = []
var shader:RID
var rendering_device :RenderingDevice = RenderingServer.create_local_rendering_device()
var pos_in_buffer:RID
var pos_out_buffer:RID
var target_in_buffer:RID

func update_data(positions:Array[Vector2], targets:Array[Vector2])->void:
	positions_array = PackedVector2Array(positions)
	targets_array = PackedVector2Array(targets)
	pass

func move_chickens(delta:float)->Array[Vector2]:
	if !shader.is_valid():
		_build_shader()
	
	_run_shader(delta)
	_retrieve_shader_data()
	
	return position_output

func _retrieve_shader_data()->void:
	if pos_out_buffer.is_valid():
		var pos_output :PackedByteArray=  rendering_device.buffer_get_data(pos_out_buffer)
		var arr :Array[Vector2]= _byte_array_to_vec2_array(pos_output)
		position_output = arr
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
	
	var pos_byte_array:PackedByteArray = positions_array.to_byte_array()
	if pos_in_buffer.is_valid():
		rendering_device.free_rid(pos_in_buffer)
	pos_in_buffer = rendering_device.storage_buffer_create(pos_byte_array.size(), pos_byte_array)
	var pos_in_uniform :RDUniform = RDUniform.new()
	pos_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	pos_in_uniform.binding = 0
	pos_in_uniform.add_id(pos_in_buffer)
	
	# Position output buffer
	if pos_out_buffer.is_valid():
		rendering_device.free_rid(pos_out_buffer)
	pos_out_buffer = rendering_device.storage_buffer_create(pos_byte_array.size(), pos_byte_array)
	var pos_out_uniform :RDUniform = RDUniform.new()
	pos_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	pos_out_uniform.binding = 1
	pos_out_uniform.add_id(pos_out_buffer)
	
	var tar_byte_array:PackedByteArray = targets_array.to_byte_array()
	if target_in_buffer.is_valid():
		rendering_device.free_rid(target_in_buffer)
	target_in_buffer = rendering_device.storage_buffer_create(tar_byte_array.size(), tar_byte_array)
	var tar_in_uniform :RDUniform = RDUniform.new()
	tar_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	tar_in_uniform.binding = 2
	tar_in_uniform.add_id(target_in_buffer)
	
	var movement_uniform_set :RID= rendering_device.uniform_set_create([
		pos_in_uniform, 
		pos_out_uniform, 
		tar_in_uniform,
		], shader, 0)
	
	# Create a compute pipeline
	var pipeline :RID = rendering_device.compute_pipeline_create(shader)
	var compute_list :int= rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rendering_device.compute_list_bind_uniform_set(compute_list, movement_uniform_set, 0)
	rendering_device.compute_list_set_push_constant(compute_list, parameters, parameters.size())
	var work_group_size:int = positions_array.size()/100 + positions_array.size()%100
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
	return parameters

func _build_shader()->void:
	var shader_file:Resource = load("res://scripts/chicken_manager/chicken_mover.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rendering_device.shader_create_from_spirv(shader_spirv)
	pass
