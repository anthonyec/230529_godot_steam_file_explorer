class_name Screen
extends Window

signal close

func _ready() -> void:
#	borderless = true
	maximize_screen(self)
	
	# TODO: Fix this so it doesn't randomly refer to parent, but gets the root.
	get_parent().connect("resized", maximize_screen.bind(self))
	connect("focus_entered", _on_focus_entered)
	connect("focus_exited", _on_focus_exited)
	
func maximize_screen(screen: Screen) -> void:
	var viewport_size = get_parent().get_viewport().size
	
	screen.size = Vector2i(viewport_size.x, viewport_size.y)
	screen.position = Vector2i(0, 0)
	
func _on_focus_entered() -> void:
	set_process_input(true)
	
func _on_focus_exited() -> void:
	set_process_input(false)

func open(path: String) -> void:
	pass
