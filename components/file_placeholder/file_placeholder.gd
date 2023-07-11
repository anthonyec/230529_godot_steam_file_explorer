class_name FilePlaceholder
extends Panel

@export var file: File

@onready var label: Label = %Label

func _ready() -> void:
	label.text = file.file_name
