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
	
func _exit_tree() -> void:
	queue_free()
	
func maximize_screen(screen: Screen) -> void:
	var viewport_size = get_parent().get_viewport().size
		
	# TDOO: Ideally the main scene would control this, but oh well.
	var control_bar = get_parent().get_node_or_null("ControlBar")
	var control_bar_height: int = 0
	
	if control_bar:
		control_bar = control_bar as Window
		control_bar_height = control_bar.size.y
	
	screen.size = Vector2i(viewport_size.x, viewport_size.y - control_bar_height)
	screen.position = Vector2i(0, 0)
	
func _on_focus_entered() -> void:
	set_process_input(true)
	
func _on_focus_exited() -> void:
	set_process_input(false)

func open(_path: String) -> void:
	pass

func get_controls() -> Dictionary:
	return {}
