class_name FileItem
extends Button

@export var file: File = null

@onready var icon_texture: TextureRect = %Icon as TextureRect
@onready var label: Label = %Label as Label

var folder_icon_texture: Texture2D = preload("res://entities/files/folder_icon.tres")
var file_icon_texture: Texture2D = preload("res://entities/files/file_icon.tres")

func _ready() -> void:
	if disabled:
		modulate = Color(1, 1, 1, 0.2)
		
	if file.is_directory:
		icon_texture.texture = folder_icon_texture
	else:
		icon_texture.texture = file_icon_texture
		
	label.text = file.file_name
	
	if file.extension == "png" or file.extension == "jpg" or file.extension == "jpeg":
		Thumbnails.get_thumbnail(file.path, func(image): 
			var thumbnail_texture = ImageTexture.create_from_image(image)
			icon_texture.texture = thumbnail_texture
		)
	
