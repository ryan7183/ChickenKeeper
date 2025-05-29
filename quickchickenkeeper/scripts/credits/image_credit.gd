extends Control

@export_multiline var credit_text:String
@export var image:Texture

@export var credit_label:Label
@export var image_container:TextureRect

func _ready() -> void:
	credit_label.text = credit_text
	image_container.texture = image
	pass
