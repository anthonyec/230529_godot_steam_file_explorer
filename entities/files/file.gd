extends Button

var file_icon_texture: Texture2D = preload("res://entities/files/file_icon.tres")

func _ready() -> void:
	var extension = text.get_extension()
	
	if not extension.is_empty():
		set_button_icon(file_icon_texture)
	
