class_name Camera extends Camera2D


enum PanState {MOUSE_PAN, KEY_PAN, NOTHING}
enum ZoomState {OUT, IN, NOTHING}

@export var mouse_pan_speed: float = 0.1
@export var key_pan_speed: float = 20.0
@export var camera_zoom_speed:float = 0.05
@export var touch_pan_threshold:float = 5000
@export var touch_pan_speed:float = 2

var pan_state:PanState = PanState.NOTHING
var zoom_state:ZoomState = ZoomState.NOTHING
var last_middle_click_location: Vector2 = Vector2(0,0)
var camera_key_press_pan_velocity:Vector2 = Vector2(0,0)

var scroll_disabled: bool = false

var world_size:Vector2 = Vector2(2000, 2000)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if pan_state == PanState.MOUSE_PAN:
		var current_mouse_pos:Vector2 = get_viewport().get_mouse_position()
		position += (current_mouse_pos - last_middle_click_location)*mouse_pan_speed
		pass
	elif pan_state == PanState.KEY_PAN:
		position += camera_key_press_pan_velocity
		pass
	pass

func get_save_data()->Dictionary:
	return {
		"position":position
	}

func apply_save_data(data:Dictionary)->void:
	position = str_to_var("Vector2" +data["position"] as String)
	pass

func _input(event: InputEvent) -> void:
	
	_handle_key_camera_pan()
	
	_handle_mouse_camera_pan(event)
	
	_handle_camera_zoom(event)
	
	_handle_touch_input(event)
	
	pass

func _handle_touch_input(event: InputEvent)->void:
	if event is InputEventPanGesture:
		position += event.delta *touch_pan_speed
	elif event is InputEventMagnifyGesture:
		var zoom_factor:float = (1 - event.factor)/2
		var z:Vector2 = zoom - Vector2(zoom_factor,zoom_factor) 
		z = z.clamp(Vector2(0.05,0.05),Vector2(2,2))
		zoom = z
	pass

func _handle_key_camera_pan()->void:
	
	var input_direction:Vector2 = Input.get_vector( "CameraWest", "CameraEast", "CameraNorth", "CameraSouth")
	camera_key_press_pan_velocity = input_direction * key_pan_speed
	if camera_key_press_pan_velocity.x !=0 or camera_key_press_pan_velocity.y != 0:
		pan_state = PanState.KEY_PAN
	elif pan_state != PanState.MOUSE_PAN:
		pan_state = PanState.NOTHING
	pass

func _handle_mouse_camera_pan(event:InputEvent)->void:
	if event.is_action_pressed("CameraClickPan"):
		pan_state = PanState.MOUSE_PAN
		last_middle_click_location = event.position
	elif pan_state != PanState.KEY_PAN and event.is_action_released("CameraClickPan"):
		pan_state = PanState.NOTHING
	pass

func _handle_camera_zoom(event:InputEvent)->void:
	if !scroll_disabled and event.is_action_pressed("CameraScrollUp"):
		var z:Vector2 = zoom + Vector2(camera_zoom_speed, camera_zoom_speed)
		z = z.clamp(Vector2(0.05,0.05),Vector2(2,2))
		zoom = z
		pass
	elif !scroll_disabled and event.is_action_pressed("CameraScrollDown"):
		var z:Vector2 = zoom - Vector2(camera_zoom_speed, camera_zoom_speed)
		z = z.clamp(Vector2(0.05,0.05),Vector2(2,2))
		zoom = z
		pass
	pass
