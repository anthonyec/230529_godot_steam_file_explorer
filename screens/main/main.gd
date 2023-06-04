extends Control

@onready var browser_screen: Browser = %Browser as Browser

var current_screen: Window = null

func _ready() -> void:
	AppState.connect("moving_file_updated", _on_app_state_moving_file_updated)
	
	ContextMenu.connect("menu_opened", _on_context_menu_opened)
	ContextMenu.connect("menu_closed", _on_context_menu_closed)

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
		push_error("Screen does not have `close` signal: ", screen_name)
		return
		
	# Disable browser screen processing to stop keyboard events.
	browser_screen.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Show the new screen.
	current_screen = screen
	add_child(current_screen)
	
	# Setup the new screen.
	current_screen.connect("close", _on_screen_close)
	current_screen.open(path)
	
	# Focus the new screen.
	current_screen.grab_focus()

func close_screen() -> void:
	if not current_screen:
		push_error("Current screen was not found")
		return
	
	# Focus the browser window.
	browser_screen.grab_focus()
	
	# Remove the current screen.
	remove_child(current_screen)
	current_screen.queue_free()

	# Reset the current screen.
	current_screen = null
	
	# Enable browser screen processing to start keyboard events only *after*
	# removing the other screen.
	browser_screen.process_mode = Node.PROCESS_MODE_INHERIT

func _on_screen_close() -> void:
	close_screen()

func _on_browser_open_file(path: String) -> void:
	if current_screen:
		return
	
	match path.get_extension():
		"json", "txt":
			SFX.play_everywhere("select")
			open_screen("text_viewer", path)
		"png":
			SFX.play_everywhere("select")
			open_screen("image_viewer", path)
			
		"zip":
			SFX.play_everywhere("select")
			open_screen("archive_extractor", path)
		
		_:
			SFX.play_everywhere("invalid")

func _on_context_menu_move(file: File) -> void:
	AppState.moving_file = file
	browser_screen.interaction_mode = browser_screen.InteractionMode.SELECT_DIRECTORY
	
	print("Start moving file: ", file)
	
func _on_browser_show_options(file: File) -> void:
	if AppState.browser_mode != AppState.BrowserMode.DEFAULT:
		return

	ContextMenu.show([
		{ "label": "Move", "callback": _on_context_menu_move.bind(file) },
		{ "label": "Copy", "callback": func(): print("copy!") },
		{ "label": "Info", "callback": func(): print("info!") },
	])

func _on_context_menu_opened() -> void:
	browser_screen.process_mode = Node.PROCESS_MODE_DISABLED
	
	if current_screen:
		current_screen.process_mode = Node.PROCESS_MODE_DISABLED
	
func _on_context_menu_closed() -> void:
	browser_screen.process_mode = Node.PROCESS_MODE_INHERIT
	browser_screen.grab_focus()
	
	if current_screen:
		current_screen.process_mode = Node.PROCESS_MODE_INHERIT
		current_screen.grab_focus()


func _on_browser_select_current_directory(path: String) -> void:
	if AppState.moving_file == null:
		return
		
	if AppState.moving_file.path.get_base_dir() == path:
		print("Already exists in this folder, cancelling move")
		AppState.moving_file = null
		return
	
	FS.move(AppState.moving_file.path, path)
	AppState.moving_file = null

func _on_app_state_moving_file_updated() -> void:	
	if AppState.moving_file != null:
		browser_screen.interaction_mode = browser_screen.InteractionMode.SELECT_DIRECTORY
	else:
		browser_screen.interaction_mode = browser_screen.InteractionMode.BROWSE
