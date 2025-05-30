@tool
class_name ImageCredit extends Control

@export var image:Texture
@export_multiline var asset_title:String
@export_multiline var author:String
@export_multiline var url:String
@export_multiline var license:String
@export_multiline var license_url:String

#@export var credit_label:Label
@export var asset_title_text:RichTextLabel
@export var author_text:RichTextLabel
@export var url_text:RichTextLabel
@export var license_text:RichTextLabel

@export var image_container:TextureRect

func _ready() -> void:
	asset_title_text.text = asset_title
	author_text.text = author
	url_text.text = '[url={"url": "'+url+'"}]'+url+'[/url]'
	license_text.text = '[url={"url": "'+license_url+'"}]'+license+'[/url]'
	image_container.texture = image
	pass


func _on_url_meta_clicked(meta: Variant) -> void:
	var data:Dictionary = JSON.parse_string(meta)
	if data.has("url"):
		var site:String = data["url"]
		OS.shell_open(site)
	pass # Replace with function body.
