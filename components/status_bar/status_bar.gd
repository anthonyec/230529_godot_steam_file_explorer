class_name StatusBar
extends Window

@onready var container: HBoxContainer = %HBoxContainer

func _ready() -> void:
	get_parent().connect("resized", _on_parent_resize)
	_on_parent_resize()

func _on_parent_resize() -> void:
	var viewport_size = get_parent().get_viewport().size
	size.x = viewport_size.x
	position.y = viewport_size.y - size.y
