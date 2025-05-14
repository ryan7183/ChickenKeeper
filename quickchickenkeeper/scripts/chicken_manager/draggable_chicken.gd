class_name DraggableChicken extends Sprite2D

@export var image:Sprite2D

signal dropped(pos:Vector2, data:Dictionary)
var chicken_sprite_size:int  =24
var world_size:Vector2 = Vector2(2000,2000)

func _process(_delta: float) -> void:
	var new_pos:Vector2 = get_global_mouse_position()
	var viewport_size:Vector2 = get_viewport().get_visible_rect().size
	var max_x:float = world_size.x-(chicken_sprite_size*scale.x)
	var max_y:float = world_size.y-(chicken_sprite_size*scale.y)
	new_pos.x = min(max(0,new_pos.x),max_x)
	new_pos.y = min(max(0,new_pos.y),max_y)
	set_position(new_pos)
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_released("PickUpChicken"):
		dropped.emit(position)
		queue_free()
