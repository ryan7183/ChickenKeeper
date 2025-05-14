class_name DraggableChicken extends Control

@export var image:Sprite2D

signal dropped(pos:Vector2, data:Dictionary)

func _process(_delta: float) -> void:
	var new_pos:Vector2 = get_global_mouse_position()
	var viewport_size:Vector2 = get_viewport().get_visible_rect().size
	var max_x:float = viewport_size.x-(size.x*scale.x)
	var max_y:float = viewport_size.y-(size.y*scale.y)
	new_pos.x = min(max(0,new_pos.x),max_x)
	new_pos.y = min(max(0,new_pos.y),max_y)
	set_position(new_pos)
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_released("PickUpChicken"):
		dropped.emit(position)
		queue_free()
