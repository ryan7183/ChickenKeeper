@tool
class_name RoleCredit extends Control

@export_multiline var credit_text:String
@export var credit_label:RichTextLabel
@export_multiline var link_url:String

func _ready() -> void:
	credit_label.text = '[url={"url": "'+link_url+'"}]'+credit_text+'[/url]'
	pass

func _on_label_meta_clicked(meta: Variant) -> void:
	var data:Dictionary = JSON.parse_string(meta)
	if data.has("url"):
		var site:String = data["url"]
		OS.shell_open(site)
	pass # Replace with function body.
