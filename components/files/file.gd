class_name FileItem
extends Button

@export var file: File = null

@onready var icon_texture: TextureRect = %Icon as TextureRect
@onready var label: Label = %Label as Label
@onready var rendered: bool = true

const folder_icon_texture: Texture2D = preload("res://components/files/folder_black_36dp.svg")
const file_icon_texture: Texture2D = preload("res://components/files/insert_drive_file_black_36dp.svg")

func _ready() -> void:
	file.connect("changed", _on_file_changed)
	
	var other_colors: float = 0.0 if file.is_selected else 1.0
	var opacity: float = 0.2 if file.is_disabled else 1.0
	
	print(file.file_name, " ", file.is_disabled, opacity)
	
	modulate = Color(other_colors, other_colors, other_colors, opacity)
	disabled = file.is_disabled
#
	if file.is_directory:
		icon_texture.texture = folder_icon_texture
	else:
		icon_texture.texture = file_icon_texture
		
	label.text = file.file_name
	
	connect("resized", _on_resized)
	_on_resized()

#	if file.extension == "png" or file.extension == "jpg" or file.extension == "jpeg":
#		Thumbnails.get_thumbnail(file.path, func(image): 
#			var thumbnail_texture = ImageTexture.create_from_image(image)
#			icon_texture.texture = thumbnail_texture
#		)

func _on_resized() -> void:
	pivot_offset = size / 2

func _exit_tree() -> void:
	file.queue_free() # @PREVENT_MEMORY_LEAK
	queue_free() # @PREVENT_MEMORY_LEAK
	
func _on_file_changed(property_name: String, _previous_value: Variant, _next_value: Variant) -> void:
	if property_name == "is_selected":
		var other_colors: float = 0.0 if file.is_selected else 1.0
		var tween = get_tree().create_tween()
		
		tween.tween_property(self, "modulate", Color(other_colors, other_colors, other_colors, 1), 0.1)
		tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
		
	if property_name == "is_disabled":
		var opacity: float = 0.2 if file.is_disabled == true else 1.0
		var tween = get_tree().create_tween()
		
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "modulate", Color(1, 1, 1, opacity), 0.2)
