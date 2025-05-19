class_name ChickenActionChooser extends Node



var packed_chicken_positions:PackedVector2Array = []
var packed_chicken_hunger_satiation: PackedFloat32Array = []
var packed_chicken_fatigue:PackedFloat32Array= []
var packed_chicken_target:PackedVector2Array = []
var packed_terrain: PackedInt32Array = []
var packed_chicken_current_action: PackedInt32Array = []
var terrain_width:int

var shader:RID
var rendering_device :RenderingDevice = RenderingServer.create_local_rendering_device()
var pos_in_buffer:RID
var target_in_buffer:RID
var target_out_buffer:RID
var terrain_in_buffer:RID
var hunger_satiation_in_buffer:RID
var chicken_fatigue_in_buffer:RID
var chicken_current_action_out_buffer:RID
var tile_size:int

var target_output:Array[Vector2]= []
var action_output:Array[ChickenManager.Action] = []

func update_data(positions:Array[Vector2], hunger_satiation:Array[float], chicken_fatigue:Array[float], targets:Array[Vector2], terrain:Array[Array])->void:
	packed_chicken_positions = PackedVector2Array(positions)
	packed_chicken_hunger_satiation = PackedFloat32Array(hunger_satiation)
	packed_chicken_fatigue = PackedFloat32Array(chicken_fatigue)
	packed_chicken_target = PackedVector2Array(targets)
	terrain_width = positions.size()
	packed_terrain = _terrain_to_packed(terrain)
	pass

func _terrain_to_packed(terrain:Array[Array])->PackedInt32Array:
	var new_arr:Array[int]=[]
	for arr:Array in terrain:
		new_arr.append_array(arr)
	return PackedInt32Array(new_arr)

func decide_chicken_action(delta:float)->Dictionary:
	if !shader.is_valid():
		_build_shader()
	
	_run_shader(delta)
	_retrieve_shader_data()
	
	return {
		"target":target_output,
		"action":action_output,
	}

func _retrieve_shader_data()->void:
	if target_out_buffer.is_valid():
		var tar_output :PackedByteArray=  rendering_device.buffer_get_data(target_out_buffer)
		var arr :Array[Vector2]= _byte_array_to_vec2_array(tar_output)
		target_output = arr
		
	if chicken_current_action_out_buffer.is_valid():
		var action_out :PackedByteArray=  rendering_device.buffer_get_data(chicken_current_action_out_buffer)
		var arr :Array[ChickenManager.Action]= Array(Array(action_out.to_int32_array()),TYPE_INT,"",null)# There must be a better way than doing it twice
		action_output = arr 
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
	
	var pos_byte_array:PackedByteArray = packed_chicken_positions.to_byte_array()
	if pos_in_buffer.is_valid():
		rendering_device.free_rid(pos_in_buffer)
	pos_in_buffer = rendering_device.storage_buffer_create(pos_byte_array.size(), pos_byte_array)
	var pos_in_uniform :RDUniform = RDUniform.new()
	pos_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	pos_in_uniform.binding = 0
	pos_in_uniform.add_id(pos_in_buffer)
	
	var tar_byte_array:PackedByteArray = packed_chicken_target.to_byte_array()
	if target_in_buffer.is_valid():
		rendering_device.free_rid(target_in_buffer)
	target_in_buffer = rendering_device.storage_buffer_create(tar_byte_array.size(), tar_byte_array)
	var target_in_uniform :RDUniform = RDUniform.new()
	target_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	target_in_uniform.binding = 1
	target_in_uniform.add_id(target_in_buffer)
	
	# Position output buffer
	if target_out_buffer.is_valid():
		rendering_device.free_rid(target_out_buffer)
	target_out_buffer = rendering_device.storage_buffer_create(tar_byte_array.size(), tar_byte_array)
	var target_out_uniform :RDUniform = RDUniform.new()
	target_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	target_out_uniform.binding = 2
	target_out_uniform.add_id(target_out_buffer)
	
	var terrain_byte_array:PackedByteArray = packed_terrain.to_byte_array()
	if terrain_in_buffer.is_valid():
		rendering_device.free_rid(terrain_in_buffer)
	terrain_in_buffer = rendering_device.storage_buffer_create(terrain_byte_array.size(), terrain_byte_array)
	var terrain_in_uniform :RDUniform = RDUniform.new()
	terrain_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	terrain_in_uniform.binding = 3
	terrain_in_uniform.add_id(terrain_in_buffer)
	
	var hunger_byte_array:PackedByteArray = packed_chicken_hunger_satiation.to_byte_array()
	if hunger_satiation_in_buffer.is_valid():
		rendering_device.free_rid(hunger_satiation_in_buffer)
	hunger_satiation_in_buffer = rendering_device.storage_buffer_create(hunger_byte_array.size(), hunger_byte_array)
	var hunger_satiation_uniform :RDUniform = RDUniform.new()
	hunger_satiation_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	hunger_satiation_uniform.binding = 4
	hunger_satiation_uniform.add_id(hunger_satiation_in_buffer)
	
	var fatigue_byte_array:PackedByteArray = packed_chicken_fatigue.to_byte_array()
	if chicken_fatigue_in_buffer.is_valid():
		rendering_device.free_rid(chicken_fatigue_in_buffer)
	chicken_fatigue_in_buffer = rendering_device.storage_buffer_create(fatigue_byte_array.size(), fatigue_byte_array)
	var chicken_fatigue_uniform :RDUniform = RDUniform.new()
	chicken_fatigue_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	chicken_fatigue_uniform.binding = 5
	chicken_fatigue_uniform.add_id(chicken_fatigue_in_buffer)
	
	var action_array:Array[int] = []
	action_array.resize(packed_chicken_positions.size())
	action_array.fill(0)
	var action_byte_array:PackedByteArray = PackedInt32Array(action_array).to_byte_array()#packed_terrain.to_byte_array()
	if chicken_current_action_out_buffer.is_valid():
		rendering_device.free_rid(chicken_current_action_out_buffer)
	chicken_current_action_out_buffer = rendering_device.storage_buffer_create(action_byte_array.size(), action_byte_array)
	var action_out_uniform :RDUniform = RDUniform.new()
	action_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	action_out_uniform.binding = 6
	action_out_uniform.add_id(chicken_current_action_out_buffer)
	
	var action_uniform_set :RID= rendering_device.uniform_set_create([
		pos_in_uniform,
		target_in_uniform,
		target_out_uniform,
		terrain_in_uniform,
		hunger_satiation_uniform,
		chicken_fatigue_uniform,
		action_out_uniform,
		], shader, 0)
	
	# Create a compute pipeline
	var pipeline :RID = rendering_device.compute_pipeline_create(shader)
	var compute_list :int= rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rendering_device.compute_list_bind_uniform_set(compute_list, action_uniform_set, 0)
	rendering_device.compute_list_set_push_constant(compute_list, parameters, parameters.size())
	var work_group_size:int = packed_chicken_positions.size()/100 + packed_chicken_positions.size()%100
	rendering_device.compute_list_dispatch(compute_list,  work_group_size, 1, 1)
	rendering_device.compute_list_end()
	
	if action_uniform_set.is_valid():
		rendering_device.free_rid(action_uniform_set)
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
