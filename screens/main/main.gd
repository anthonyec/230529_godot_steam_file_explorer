extends Control

@onready var browser: Browser = %Browser as Browser

var current_screen: Control = null

func _on_browser_open_file(path: String) -> void:
	if path.get_extension() != "png":
		return
	
	if current_screen:
		return
		
	var image_viewer_resource: Resource = preload("res://screens/image_viewer/image_viewer.tscn")
	var image_viewer: Screen = image_viewer_resource.instantiate() as Screen
	
	current_screen = image_viewer
	add_child(current_screen)
	
	current_screen.connect("close", _on_screen_close)
	current_screen.open(path)


func _on_screen_close() -> void:
	if current_screen:
		remove_child(current_screen)
		current_screen = null
