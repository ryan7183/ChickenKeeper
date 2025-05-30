@tool
class_name ImageCredit extends Control

@export var image:Texture
@export_multiline var asset_title:String
@export_multiline var author:String
@export_multiline var url:String
@export_multiline var license:String


#@export var credit_label:Label
@export var asset_title_text:RichTextLabel
@export var author_text:RichTextLabel
@export var url_text:RichTextLabel
@export var license_text:RichTextLabel

@export var image_container:TextureRect

func _ready() -> void:
	asset_title_text.text = asset_title
	author_text.text = author
	url_text.text = url
	license_text.text = license
	image_container.texture = image
	pass
