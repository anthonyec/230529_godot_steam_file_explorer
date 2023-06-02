extends Screen

@onready var texture_rect: TextureRect = %TextureRect as TextureRect

func _ready() -> void:
	super()
	$Panel/CloseButton.grab_focus()

func open(path: String) -> void:
	pass

func _on_close_button_pressed() -> void:
	close.emit()
