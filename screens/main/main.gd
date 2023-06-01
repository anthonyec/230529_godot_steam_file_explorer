extends Control

@onready var browser_screen: Browser = %Browser as Browser

var current_screen: Control = null
var browser_screenshot: TextureRect = null

func _on_browser_open_file(path: String) -> void:
	if current_screen:
		return
	
	match path.get_extension():
		"png":
			SFX.play_everywhere("select")
			open_screen("image_viewer", path)
			
		"zip":
			SFX.play_everywhere("select")
			open_screen("archive_extractor", path)
		
		_:
			SFX.play_everywhere("invalid")

func open_screen(screen_name: String, path: String) -> void:
	var screen_resource: Resource = load("res://screens/" + screen_name + "/" + screen_name + ".tscn")
	
	if not screen_resource:
		push_error("Failed to load screen resouce: ", screen_name)
		return
		
	var screen: Screen = screen_resource.instantiate() as Screen
	
	if not screen.has_method("open"):
		push_error("Screen does not have `open` method: ", screen_name)
		return
		
	if not screen.has_signal("close"):
		push_error("Screen does not have close` signal: ", screen_name)
		return
	
	# Take a screenshot of the browser to use behind screens to give the 
	# appearance the old focus is still active but not interactable.
	var browser_viewport_image = browser_screen.get_viewport().get_texture().get_image()
	var browser_viewport_texture = ImageTexture.create_from_image(browser_viewport_image)
	
	browser_screenshot = TextureRect.new()
	browser_screenshot.texture = browser_viewport_texture	
	add_child(browser_screenshot)
	
	# Show the new screen.
	current_screen = screen
	add_child(current_screen)
	
	# Setup the new screen.
	current_screen.connect("close", _on_screen_close)
	current_screen.open(path)
	
	# Hide browser screen.
	browser_screen.visible = false
	browser_screen.process_mode = Node.PROCESS_MODE_DISABLED

	# Animate out the browser screenshot.
	var tween = get_tree().create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(browser_screenshot, "position", Vector2(20, 10), 0.3) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(browser_screenshot, "scale", Vector2(0.95, 0.95), 0.3) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
func close_screen() -> void:
	if not current_screen:
		push_error("Current screen was not found")
		return
	
	# Show browser screen.
	browser_screen.visible = true
	browser_screen.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Remove the current screen.
	remove_child(current_screen)
	current_screen.queue_free()
	
	# Remove the browser screenshot.
	remove_child(browser_screenshot)
	browser_screenshot.queue_free()

	# Reset the current screen.
	current_screen = null
	
	# Animate in the browser screen.
	var tween = get_tree().create_tween()
	
	tween.tween_property(browser_screen, "scale", Vector2(1, 1), 0.3) \
		.from(Vector2(0.95, 0.95)) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
		
	await tween.finished

func _on_screen_close() -> void:
	close_screen()
