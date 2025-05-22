class_name ChickenActionPerformer extends Resource


var packed_positions_array:PackedVector2Array = []
var packed_food_amount: PackedFloat32Array = []
var packed_hunger_satiation:PackedFloat32Array = []
var packed_fatigue_amount:PackedFloat32Array = []
var packed_chicken_action:PackedInt32Array = []
var packed_satisfaction:PackedFloat32Array = []
var packed_chicken_health: PackedFloat32Array = []

var terrain_width:int
var shader:RID
var rendering_device :RenderingDevice = RenderingServer.create_local_rendering_device()
var pos_in_buffer:RID
var food_in_buffer:RID
#var food_out_buffer:RID
var hunger_in_buffer:RID
var hunger_out_buffer:RID
var fatigue_in_buffer:RID
var fatigue_out_buffer:RID
var action_in_buffer:RID
var satisfaction_in_buffer:RID
var satisfaction_out_buffer:RID
var health_in_buffer:RID
var health_out_buffer:RID

var food_output:Array[Array]
var hunger_output:Array[float]
var fatigue_output:Array[float]
var satisfaction_output:Array[float]
var health_output:Array[float]

var num_chickens:int

func update_data(positions:Array[Vector2], food:Array[Array], hunger:Array[float],\
 fatigue:Array[float], action:Array[ChickenManager.Action], satisfaction:Array[float],\
 chicken_health:Array[float])->void:
	packed_positions_array = PackedVector2Array(positions)
	terrain_width = food.size()
	packed_food_amount = _food_to_packed(food)
	packed_fatigue_amount = PackedFloat32Array(fatigue)
	packed_hunger_satiation = PackedFloat32Array(hunger)
	num_chickens = positions.size()
	packed_chicken_action = PackedInt32Array(action)
	packed_satisfaction = PackedFloat32Array(satisfaction)
	packed_chicken_health= PackedFloat32Array(chicken_health)
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

func perform_chicken_actions()->Dictionary:
	if !shader.is_valid():
		_build_shader()
	
	_run_shader()
	_retrieve_shader_data()
	
	return {
		"food":food_output,
		"hunger":hunger_output,
		"fatigue":fatigue_output,
		"satisfaction":satisfaction_output,
		"health":health_output,
	}

func _retrieve_shader_data()->void:
	if food_in_buffer.is_valid():
		var food_out :PackedByteArray=  rendering_device.buffer_get_data(food_in_buffer)
		var arr :PackedFloat32Array= food_out.to_float32_array()
		food_output = one_d_to_two_d_square_array(Array(arr),terrain_width)
	if hunger_out_buffer.is_valid():
		var hunger_out :PackedByteArray=  rendering_device.buffer_get_data(hunger_out_buffer)
		var arr :PackedFloat32Array= hunger_out.to_float32_array()
		hunger_output = Array(Array(arr),TYPE_FLOAT,"",null)
	if fatigue_out_buffer.is_valid():
		var fatigue_out :PackedByteArray=  rendering_device.buffer_get_data(fatigue_out_buffer)
		var arr :PackedFloat32Array= fatigue_out.to_float32_array()
		fatigue_output = Array(Array(arr),TYPE_FLOAT,"",null)
	if satisfaction_out_buffer.is_valid():
		var satisfaction_out :PackedByteArray=  rendering_device.buffer_get_data(satisfaction_out_buffer)
		var arr :PackedFloat32Array= satisfaction_out.to_float32_array()
		satisfaction_output = Array(Array(arr),TYPE_FLOAT,"",null)
	if health_out_buffer.is_valid():
		var health_out :PackedByteArray=  rendering_device.buffer_get_data(health_out_buffer)
		var arr :PackedFloat32Array= health_out.to_float32_array()
		health_output = Array(Array(arr),TYPE_FLOAT,"",null)
	pass

func one_d_to_two_d_square_array(arr:Array, width:int)->Array[Array]:
	var new_arr:Array[Array] = []
	new_arr.resize(width)
	for x:int in range(width):
		var col:Array = []
		col.resize(width)
		for y:int in range(width):
			col[y] = arr[(x*width)+y]
			pass
		new_arr[x] = col
	return new_arr

func _byte_array_to_vec2_array(bytes:PackedByteArray)->Array[Vector2]:
	var decoded :Array = bytes.to_float32_array()
	var arr: Array[Vector2] = []
	for i:int in range(1,decoded.size(),2):
		arr.append(Vector2(decoded[i-1],decoded[i]))
		pass
	
	return arr

func _run_shader()->void:
	
	var parameters:PackedByteArray = _make_movement_shader_parameters()
	
	var pos_byte_array:PackedByteArray = packed_positions_array.to_byte_array()
	if pos_in_buffer.is_valid():
		rendering_device.free_rid(pos_in_buffer)
	pos_in_buffer = rendering_device.storage_buffer_create(pos_byte_array.size(), pos_byte_array)
	var pos_in_uniform :RDUniform = RDUniform.new()
	pos_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	pos_in_uniform.binding = 0
	pos_in_uniform.add_id(pos_in_buffer)
	
	var food_byte_array:PackedByteArray = packed_food_amount.to_byte_array()
	if food_in_buffer.is_valid():
		rendering_device.free_rid(food_in_buffer)
	food_in_buffer = rendering_device.storage_buffer_create(food_byte_array.size(), food_byte_array)
	var food_in_uniform :RDUniform = RDUniform.new()
	food_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	food_in_uniform.binding = 1
	food_in_uniform.add_id(food_in_buffer)
	
	#if food_out_buffer.is_valid():
	#	rendering_device.free_rid(food_out_buffer)
	#food_out_buffer = rendering_device.storage_buffer_create(food_byte_array.size(), food_byte_array)
	#var food_out_uniform :RDUniform = RDUniform.new()
	#food_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	#food_out_uniform.binding = 2
	#food_out_uniform.add_id(food_out_buffer)
	
	var hunger_byte_array:PackedByteArray = packed_hunger_satiation.to_byte_array()
	if hunger_in_buffer.is_valid():
		rendering_device.free_rid(hunger_in_buffer)
	hunger_in_buffer = rendering_device.storage_buffer_create(hunger_byte_array.size(), hunger_byte_array)
	var hunger_in_uniform :RDUniform = RDUniform.new()
	hunger_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	hunger_in_uniform.binding = 3
	hunger_in_uniform.add_id(hunger_in_buffer)
	
	if hunger_out_buffer.is_valid():
		rendering_device.free_rid(hunger_out_buffer)
	hunger_out_buffer = rendering_device.storage_buffer_create(hunger_byte_array.size(), hunger_byte_array)
	var hunger_out_uniform :RDUniform = RDUniform.new()
	hunger_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	hunger_out_uniform.binding = 4
	hunger_out_uniform.add_id(hunger_out_buffer)
	
	var fatigue_byte_array:PackedByteArray = packed_fatigue_amount.to_byte_array()
	if fatigue_in_buffer.is_valid():
		rendering_device.free_rid(fatigue_in_buffer)
	fatigue_in_buffer = rendering_device.storage_buffer_create(fatigue_byte_array.size(), fatigue_byte_array)
	var fatigue_in_uniform :RDUniform = RDUniform.new()
	fatigue_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	fatigue_in_uniform.binding = 5
	fatigue_in_uniform.add_id(fatigue_in_buffer)
	
	if fatigue_out_buffer.is_valid():
		rendering_device.free_rid(fatigue_out_buffer)
	fatigue_out_buffer = rendering_device.storage_buffer_create(fatigue_byte_array.size(), fatigue_byte_array)
	var fatigue_out_uniform :RDUniform = RDUniform.new()
	fatigue_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	fatigue_out_uniform.binding = 6
	fatigue_out_uniform.add_id(fatigue_out_buffer)
	
	var action_byte_array:PackedByteArray = packed_chicken_action.to_byte_array()
	if action_in_buffer.is_valid():
		rendering_device.free_rid(action_in_buffer)
	action_in_buffer = rendering_device.storage_buffer_create(action_byte_array.size(), action_byte_array)
	var action_in_uniform :RDUniform = RDUniform.new()
	action_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	action_in_uniform.binding = 7
	action_in_uniform.add_id(action_in_buffer)
	
	var satisfaction_byte_array:PackedByteArray = packed_satisfaction.to_byte_array()
	if satisfaction_in_buffer.is_valid():
		rendering_device.free_rid(satisfaction_in_buffer)
	satisfaction_in_buffer = rendering_device.storage_buffer_create(satisfaction_byte_array.size(), satisfaction_byte_array)
	var satisfaction_in_uniform :RDUniform = RDUniform.new()
	satisfaction_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	satisfaction_in_uniform.binding = 8
	satisfaction_in_uniform.add_id(satisfaction_in_buffer)
	
	if satisfaction_out_buffer.is_valid():
		rendering_device.free_rid(satisfaction_out_buffer)
	satisfaction_out_buffer = rendering_device.storage_buffer_create(satisfaction_byte_array.size(), satisfaction_byte_array)
	var satisfaction_out_uniform :RDUniform = RDUniform.new()
	satisfaction_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	satisfaction_out_uniform.binding = 9
	satisfaction_out_uniform.add_id(satisfaction_out_buffer)
	
	var health_byte_array:PackedByteArray = packed_chicken_health.to_byte_array()
	if health_in_buffer.is_valid():
		rendering_device.free_rid(health_in_buffer)
	health_in_buffer = rendering_device.storage_buffer_create(health_byte_array.size(), health_byte_array)
	var health_in_uniform :RDUniform = RDUniform.new()
	health_in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	health_in_uniform.binding = 10
	health_in_uniform.add_id(health_in_buffer)
	
	if health_out_buffer.is_valid():
		rendering_device.free_rid(health_out_buffer)
	health_out_buffer = rendering_device.storage_buffer_create(health_byte_array.size(), health_byte_array)
	var health_out_uniform :RDUniform = RDUniform.new()
	health_out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	health_out_uniform.binding = 11
	health_out_uniform.add_id(health_out_buffer)
	
	var action_uniform_set :RID= rendering_device.uniform_set_create([
		pos_in_uniform, 
		food_in_uniform,
		#food_out_uniform,
		hunger_in_uniform,
		hunger_out_uniform,
		fatigue_in_uniform,
		fatigue_out_uniform,
		action_in_uniform,
		satisfaction_in_uniform,
		satisfaction_out_uniform,
		health_in_uniform,
		health_out_uniform,
		], shader, 0)
	
	# Create a compute pipeline
	var pipeline :RID = rendering_device.compute_pipeline_create(shader)
	var compute_list :int= rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rendering_device.compute_list_bind_uniform_set(compute_list, action_uniform_set, 0)
	rendering_device.compute_list_set_push_constant(compute_list, parameters, parameters.size())
	var work_group_size:int = num_chickens/100 + num_chickens%100
	rendering_device.compute_list_dispatch(compute_list,  work_group_size, 1, 1)
	rendering_device.compute_list_end()
	
	if action_uniform_set.is_valid():
		rendering_device.free_rid(action_uniform_set)
	if pipeline.is_valid():
		rendering_device.free_rid(pipeline)
	
	pass

func _make_movement_shader_parameters()->PackedByteArray:
	var parameters :PackedByteArray = PackedByteArray()
	parameters.resize(16)
	parameters.encode_u32(0,terrain_width)
	return parameters

func _build_shader()->void:
	var shader_file:Resource = load("res://scripts/chicken_manager/chicken_action_performer.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rendering_device.shader_create_from_spirv(shader_spirv)
	pass
