class_name FileItem
extends Button

@export var file: File = null

@onready var icon_texture: TextureRect = %Icon as TextureRect
@onready var label: Label = %Label as Label

var folder_icon_texture: Texture2D = preload("res://components/files/folder_icon.tres")
var file_icon_texture: Texture2D = preload("res://components/files/file_icon.tres")

func _ready() -> void:
	file.connect("changed", _on_file_changed)
	
	var other_colors = 0 if file.is_selected else 1
	var opacity = 0.2 if file.is_disabled else 1
	
	modulate = Color(other_colors, other_colors, other_colors, opacity)
	disabled = file.is_disabled
	
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
	
func _on_file_changed(property_name: String, previous_value: Variant, next_value: Variant) -> void:
	if property_name == "is_selected":
		var other_colors = 0 if file.is_selected else 1
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(other_colors, other_colors, other_colors, 1), 0.1)
		tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
		
	if property_name == "is_disabled":
		var opacity = 0.2 if file.is_disabled == true else 1
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, opacity), 0.5)
	
