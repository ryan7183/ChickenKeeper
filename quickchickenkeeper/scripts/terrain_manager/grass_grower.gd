class_name GrassGrower extends Node


var packed_terrain: PackedInt32Array = []
var packed_food:PackedFloat32Array = []
var terrain_width:int

var shader:RID
var rendering_device :RenderingDevice = RenderingServer.create_local_rendering_device()
var terrain_in_buffer:RID
var terrain_out_buffer:RID
var changed_out_buffer:RID
var food_in_buffer:RID
var food_out_buffer:RID

var terrain_output:Array[Array]= []
var changed_output:Array[Array]= []
var food_output:Array[Array] = []

func update_data(terrain:Array[Array], food:Array[Array])->void:
	terrain_width = terrain.size()
	packed_terrain = _terrain_to_packed(terrain)
	packed_food = _food_to_packed(food)
	pass

func _terrain_to_packed(terrain:Array[Array])->PackedInt32Array:
	var new_arr:Array[int]=[]
	for arr:Array in terrain:
		new_arr.append_array(arr)
	return PackedInt32Array(new_arr)

func _food_to_packed(food:Array[Array])->PackedFloat32Array:
	var new_arr:Array[float]=[]
	for arr:Array in food:
		new_arr.append_array(arr)
	return PackedFloat32Array(new_arr)

func grow_grass(delta:float)->Dictionary:
	if !shader.is_valid():
		_build_shader()
	_run_shader(delta)
	_retrieve_shader_data()
	
	var result:Dictionary = {
		"terrain":terrain_output,
		"changed":changed_output,
		"food": food_output,
	}
	
	return result

func clear_changed_output()->void:
	for arr:Array in changed_output:
		for i in arr.size():
			arr[i] = false;
		pass
	pass

func _retrieve_shader_data()->void:
	if terrain_out_buffer.is_valid():
		var terrain_out :PackedByteArray=  rendering_device.buffer_get_data(terrain_out_buffer)
		var arr :PackedInt32Array= Array(terrain_out.to_int32_array())
		terrain_output = one_d_to_two_d_square_array(Array(arr),terrain_width)
		packed_terrain = arr#_terrain_to_packed(terrain_output)
	if changed_out_buffer.is_valid():
		var changed_out :PackedByteArray=  rendering_device.buffer_get_data(changed_out_buffer)
		var arr :PackedInt32Array= Array(changed_out.to_int32_array())
		changed_output = one_d_to_two_d_square_array(Array(arr),terrain_width)
	if food_out_buffer.is_valid():
		var food_out :PackedByteArray=  rendering_device.buffer_get_data(food_out_buffer)
		var arr :PackedFloat32Array= Array(food_out.to_float32_array())
		food_output = one_d_to_two_d_square_array(Array(arr),terrain_width)
	pass

func one_d_to_two_d_square_array(arr:Array, width:int)->Array[Array]:
	var new_arr:Array[Array] = []
	for x:int in range(width):
		var col:Array = []
		for y:int in range(width):
			col.append(arr[(x*width)+y])
			pass
		new_arr.append(col)
	return new_arr

func _run_shader(delta:float)->void:
	
	var parameters:PackedByteArray = _make_movement_shader_parameters(delta)
	
	var terrain_byte_array:PackedByteArray = packed_terrain.to_byte_array()
	if terrain_in_buffer.is_valid():
		rendering_device.free_rid(terrain_in_buffer)
	terrain_in_buffer = rendering_device.storage_buffer_create(terrain_byte_array.size(), terrain_byte_array)
	var terrain_in_uniform :RDUniform = RDUniform.new()
	terrain_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	terrain_in_uniform.binding = 0
	terrain_in_uniform.add_id(terrain_in_buffer)
	
	# Position output buffer
	if terrain_out_buffer.is_valid():
		rendering_device.free_rid(terrain_out_buffer)
	terrain_out_buffer = rendering_device.storage_buffer_create(terrain_byte_array.size(), terrain_byte_array)
	var terrain_out_uniform :RDUniform = RDUniform.new()
	terrain_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	terrain_out_uniform.binding = 1
	terrain_out_uniform.add_id(terrain_out_buffer)
	
	if changed_out_buffer.is_valid():
		rendering_device.free_rid(changed_out_buffer)
	changed_out_buffer = rendering_device.storage_buffer_create(terrain_byte_array.size())
	var changed_out_uniform :RDUniform = RDUniform.new()
	changed_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	changed_out_uniform.binding = 2
	changed_out_uniform.add_id(changed_out_buffer)
	
	
	var food_byte_array:PackedByteArray = packed_food.to_byte_array()
	if food_in_buffer.is_valid():
		rendering_device.free_rid(food_in_buffer)
	food_in_buffer = rendering_device.storage_buffer_create(food_byte_array.size(),food_byte_array)
	var food_in_uniform :RDUniform = RDUniform.new()
	food_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	food_in_uniform.binding = 3
	food_in_uniform.add_id(food_in_buffer)
	
	# Position output buffer
	if food_out_buffer.is_valid():
		rendering_device.free_rid(food_out_buffer)
	food_out_buffer = rendering_device.storage_buffer_create(food_byte_array.size(),food_byte_array)
	var food_out_uniform :RDUniform = RDUniform.new()
	food_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	food_out_uniform.binding = 4
	food_out_uniform.add_id(food_out_buffer)
	
	
	var grass_uniform_set :RID= rendering_device.uniform_set_create([
		terrain_in_uniform,
		terrain_out_uniform,
		changed_out_uniform,
		food_in_uniform,
		food_out_uniform,
		], shader, 0)
	
	# Create a compute pipeline
	var pipeline :RID = rendering_device.compute_pipeline_create(shader)
	var compute_list :int= rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rendering_device.compute_list_bind_uniform_set(compute_list, grass_uniform_set, 0)
	rendering_device.compute_list_set_push_constant(compute_list, parameters, parameters.size())
	@warning_ignore("integer_division")
	var work_group_size:int = packed_terrain.size()/100 + packed_terrain.size()%100
	rendering_device.compute_list_dispatch(compute_list,  work_group_size, 1, 1)
	rendering_device.compute_list_end()
	
	if grass_uniform_set.is_valid():
		rendering_device.free_rid(grass_uniform_set)
	if pipeline.is_valid():
		rendering_device.free_rid(pipeline)
	
	pass

func _make_movement_shader_parameters(delta:float)->PackedByteArray:
	var parameters :PackedByteArray = PackedByteArray()
	parameters.resize(16)
	parameters.encode_float(0, delta)
	parameters.encode_float(4, Time.get_ticks_msec())
	parameters.encode_u32(8,terrain_width)
	return parameters

func _build_shader()->void:
	var shader_file:Resource = load("res://scripts/terrain_manager/grass_grower.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rendering_device.shader_create_from_spirv(shader_spirv)
	pass
