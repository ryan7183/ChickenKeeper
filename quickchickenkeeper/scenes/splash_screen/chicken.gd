extends Sprite2D

var chicken_look:Vector2 = Vector2(0,0)
var time_since_last_frame_change:float = 0
var current_frame:int = 0


func _process(delta: float) -> void:
	if position.x < 100:
		queue_free()
	
	position.x += -500*delta
	time_since_last_frame_change += delta
	if time_since_last_frame_change > 0.16:
		_next_frame()

func set_chicken_look(look:int)->void:
	look = look%4
	if look == 0:
		chicken_look = Vector2(3*24,0)
	if look == 1:
		chicken_look = Vector2(11*24,0)
	if look == 2:
		chicken_look = Vector2(3*24,3*24)
	if look == 3:
		chicken_look = Vector2(11*24,3*24)
	region_rect = Rect2(chicken_look.x,chicken_look.y,24,24)
	pass

func _next_frame()->void:
	current_frame = current_frame+1
	if current_frame > 2:
		current_frame = 0
	var frame_pos:int = current_frame *24
	region_rect = Rect2(chicken_look.x+frame_pos,chicken_look.y,24,24)
	time_since_last_frame_change = 0
	pass

func _on_timer_timeout() -> void:
	_next_frame()
	pass # Replace with function body.
