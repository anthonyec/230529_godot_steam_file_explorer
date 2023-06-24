class_name TextInput
extends Window

signal confirmed(text: String)
signal cancelled

@onready var input: LineEdit = %Input
@onready var cancel_button: Button = %CancelButton
@onready var done_button: Button = %DoneButton

func _ready() -> void:
	maximize_screen(self)
	
	input.grab_focus()
	input.set_caret_column(input.text.length())
	
	cancel_button.connect("pressed", _on_cancel_button_pressed)
	done_button.connect("pressed", _on_done_button_pressed)
	
func _exit_tree() -> void:
	queue_free()
	
func open(paremeters: Keyboard.Parameters) -> void:
	input.text = paremeters.value
	input.placeholder_text = paremeters.placeholder
	input
	input.set_caret_column(input.text.length())
	
func maximize_screen(screen: Window) -> void:
	var viewport_size = get_parent().get_viewport().size
	
	screen.size = Vector2i(viewport_size.x, viewport_size.y)
	screen.position = Vector2i(0, 0)

func _on_cancel_button_pressed() -> void:
	cancelled.emit()
	
func _on_done_button_pressed() -> void:
	confirmed.emit(input.text)
