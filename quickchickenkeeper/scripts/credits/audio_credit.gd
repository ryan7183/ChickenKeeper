extends Control

@export var audio_file:AudioStream
@export_multiline var credit_text:String

@export var audio_stream_player:AudioStreamPlayer2D
@export var credit_label:Label

func _ready() -> void:
	audio_stream_player.stream = audio_file
	credit_label.text = credit_text
	pass


func _on_texture_button_pressed() -> void:
	audio_stream_player.playing = !audio_stream_player.playing 
	pass # Replace with function body.
