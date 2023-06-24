extends Node

class Parameters:
	signal cancelled()
	signal confirmed(text: String)
	
	var placeholder: String
	var value: String
	var multiline: bool

var text_input_scene: PackedScene = preload("res://autoload/keyboard/text_input.tscn")
var text_input: TextInput = null
var text_input_parameters: Parameters = null

# TODO: Instead of doing this everywhere, come up with a window manager that
# manages the focuses for everything. I have a feeling bugs could appear where
# focus is lost if not managed correctly.
var previously_focused_window: Window = null
var previously_focused_control: Control = null

func present(parameters: Parameters, window_owner: Window) -> void:
	text_input = text_input_scene.instantiate() as TextInput
	text_input_parameters = parameters
	
	text_input.connect("cancelled", _on_text_input_cancelled)
	text_input.connect("confirmed", _on_text_input_confirmed)
	
	if window_owner:
		previously_focused_window = window_owner
		previously_focused_control = window_owner.get_viewport().gui_get_focus_owner()
		
	add_child(text_input)
	
	text_input.open(parameters)
	
func dismiss() -> void:
	if text_input:
		remove_child(text_input)
		
	if previously_focused_window:
		previously_focused_window.grab_focus()
		
	if previously_focused_control:
		previously_focused_control.grab_focus()

func _on_text_input_cancelled() -> void:
	dismiss()
	text_input_parameters.cancelled.emit()
	
func _on_text_input_confirmed(text: String) -> void:
	dismiss()
	text_input_parameters.confirmed.emit(text)
