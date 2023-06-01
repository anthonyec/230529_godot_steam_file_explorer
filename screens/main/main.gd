extends Control

@onready var browser_screen: Browser = %Browser as Browser

var current_screen: Control = null
var current_focused_node: Control = null
var browser_focused_node: Control = null
var browser_screenshot: TextureRect = null

func _ready() -> void:
	get_viewport().connect("gui_focus_changed", _on_gui_focus_changed)

func _on_browser_open_file(path: String) -> void:
	if path.get_extension() != "png":
		return
	
	if current_screen:
		return
		
	SFX.play_everywhere("select")

	var browser_viewport_image = browser_screen.get_viewport().get_texture().get_image()
	var browser_viewport_texture = ImageTexture.create_from_image(browser_viewport_image)
	
	browser_screenshot = TextureRect.new()
	browser_screenshot.texture = browser_viewport_texture
	
	browser_focused_node = current_focused_node
	
	add_child(browser_screenshot)
	browser_screen.visible = false
	browser_screen.process_mode = Node.PROCESS_MODE_DISABLED

	var image_viewer_resource: Resource = preload("res://screens/image_viewer/image_viewer.tscn")
	var image_viewer: Screen = image_viewer_resource.instantiate() as Screen
	
	current_screen = image_viewer
	add_child(current_screen)
	
	current_screen.grab_focus()
	current_screen.connect("close", _on_screen_close)
	current_screen.open(path)

func _on_screen_close() -> void:
	if current_screen:
		remove_child(current_screen)
		current_screen.queue_free()
		
		remove_child(browser_screenshot)
		browser_screenshot.queue_free()
		
		browser_screen.visible = true
		browser_screen.process_mode = Node.PROCESS_MODE_INHERIT
		
		if browser_focused_node:
			browser_focused_node.grab_focus()
		else:
			push_warning("Did not have last browser focused node!")

		current_screen = null

func _on_gui_focus_changed(node: Control) -> void:
	current_focused_node = node
