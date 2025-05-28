class_name ChickenAudioArea extends Node2D

@export var stream:AudioStreamRandomizer

const _initial_number_of_players:int = 0

const _max_num_players:int = 5
var max_distance:int = 2000
var _num_players:int = 0

func _ready() -> void:
	set_num_players(_initial_number_of_players)

func set_num_players(amount:int)->void:
	if amount > _num_players:
		for i:int in range(_num_players, amount):
			_add_player()
		pass
	elif  amount<_num_players:
		for i:int in range(amount,_num_players):
			_remove_player()
		pass
	pass

func _add_player()->void:
	if _max_num_players>_num_players: 
		var player:AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		player.stream = stream
		player.max_distance = max_distance
		player.volume_db = -20
		player.connect("finished", _on_background_sound_finished.bind(player))
		add_child(player)
		player.play()
		_num_players+=1
	pass
	
func _remove_player()->void:
	var children:Array = get_children()
	if children.size()>0:
		children[0].queue_free()
		_num_players-=1
	pass

func _on_background_sound_finished(player:AudioStreamPlayer2D) -> void:
	player.play()
	pass # Replace with function body.
