class_name FileItem
extends Button

@export var file: File = null

var file_icon_texture: Texture2D = preload("res://entities/files/file_icon.tres")

func _ready() -> void:
	var extension = file.file_name.get_extension()
	
	if not extension.is_empty():
		set_button_icon(file_icon_texture)
		
	text = file.file_name
	
	if file.extension == "png":
		Thumbnails.get_thumbnail(file.path, func(path): 
			var thumbnail_texture = ImageTexture.create_from_image(path)
			icon = thumbnail_texture
		)
		
	
