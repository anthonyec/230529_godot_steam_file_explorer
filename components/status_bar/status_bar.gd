class_name StatusBar
extends Window

@onready var container: HBoxContainer = %HBoxContainer

func _ready() -> void:
	get_parent().connect("resized", _on_parent_resize)
	_on_parent_resize()

func _on_parent_resize() -> void:
	var viewport_size = get_parent().get_viewport().size
	size.x = viewport_size.x
	position.y = viewport_size.y - size.y

func set_controls(controls: Dictionary) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	
	for action_name in controls.keys():
		var control = controls[action_name]
		var button = Button.new()
			
		if control.has("label"):
			button.text = control.label + "=" + action_name
		
		if control.has("callback"):
			button.connect("pressed", func():
				control.callback.call()
				button.release_focus()
			)

		button.focus_mode = Control.FOCUS_NONE
		container.add_child(button)
		
