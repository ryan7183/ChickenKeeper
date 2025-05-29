class_name DraggableChicken extends Sprite2D

@export var image:Sprite2D

signal dropped(pos:Vector2, data:Dictionary)
var tile_size:int = 16
var world_size:Vector2 = Vector2(2000,2000)

func _process(_delta: float) -> void:
	var new_pos:Vector2 = get_global_mouse_position()
	var max_x:float = (world_size.x*tile_size)#-(chicken_sprite_size*scale.x)
	var max_y:float = (world_size.y*tile_size)#-(chicken_sprite_size*scale.y)
	new_pos.x = min(max(0,new_pos.x),max_x)
	new_pos.y = min(max(0,new_pos.y),max_y)
	set_position(new_pos)
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_released("PickUpChicken"):
		dropped.emit(position)
		queue_free()

func set_chicken_image(chicken_type:int, chicken_color:int)->void:
	material.set("shader_parameter/v_frame_index",Vector2(chicken_type*8,0))
	material.set("shader_parameter/color_info",chicken_color)
	
	pass
