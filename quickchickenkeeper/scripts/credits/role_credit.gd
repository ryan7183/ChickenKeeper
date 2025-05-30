@tool
class_name RoleCredit extends Control

@export_multiline var credit_text:String
@export var credit_label:Label

func _ready() -> void:
	credit_label.text = credit_text
	pass
