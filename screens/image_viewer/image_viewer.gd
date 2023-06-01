extends Screen

@onready var texture_rect: TextureRect = %TextureRect as TextureRect

func _ready() -> void:
	super()
	$Panel/CloseButton.grab_focus()

func open(path: String) -> void:
	var image = Image.load_from_file(path)
	var texture: Texture = ImageTexture.create_from_image(image)
	
	texture_rect.texture = texture

func _on_close_button_pressed() -> void:
	close.emit()
