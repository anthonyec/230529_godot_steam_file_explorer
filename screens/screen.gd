class_name Screen
extends Window

signal close

func _ready() -> void:
	borderless = true
	maximize_screen(self)
	
	# TODO: Fix this so it doesn't randomly refer to parent, but gets the root.
	get_parent().connect("resized", maximize_screen.bind(self))
	
func maximize_screen(screen: Screen) -> void:
	var viewpoint_size = get_parent().get_viewport().size
	
	screen.size = Vector2i(viewpoint_size.x, viewpoint_size.y)
	screen.position = Vector2i(0, 0)

func open(path: String) -> void:
	pass
