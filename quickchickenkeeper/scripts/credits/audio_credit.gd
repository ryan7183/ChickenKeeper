@tool
class_name AudioCredit extends Control

@export var audio_file:AudioStream
@export_multiline var asset_title:String
@export_multiline var author:String
@export_multiline var url:String
@export_multiline var license:String


@export var asset_title_text:RichTextLabel
@export var author_text:RichTextLabel
@export var url_text:RichTextLabel
@export var license_text:RichTextLabel

@export var audio_stream_player:AudioStreamPlayer2D

func _ready() -> void:
	asset_title_text.text = asset_title
	author_text.text = author
	url_text.text = url
	license_text.text = license
	audio_stream_player.stream = audio_file
	pass


func _on_texture_button_pressed() -> void:
	audio_stream_player.playing = !audio_stream_player.playing 
	pass # Replace with function body.
