extends Screen

@onready var close_button: Button = %CloseButton
@onready var text_edit: TextEdit = %TextEdit

func _ready() -> void:
	super()
	close_button.grab_focus()

func open(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	
	if not file:
		return
		
	text_edit.text = file.get_as_text()

func _on_close_button_pressed() -> void:
	close.emit()
