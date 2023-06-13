class_name Main
extends Control

@onready var browser_screen: Browser = %Browser as Browser
@onready var status_bar: StatusBar = %StatusBar as StatusBar
@onready var state_machine: StateMachine = $StateMachine as StateMachine

var current_screen: Window = null

func _ready() -> void:
	ContextMenu.connect("menu_closed", _on_context_menu_closed)
	
	browser_screen.connect("focus_entered", _on_screen_focus_entered.bind(browser_screen))
	_on_screen_focus_entered(browser_screen)
	
func _on_screen_focus_entered(screen: Screen) -> void:
	var controls = screen.get_controls()
	status_bar.set_controls(controls)

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
	
	# Assign as current screen.
	current_screen = screen
	
	# Setup the new screen with signals.
	current_screen.connect("close", _on_screen_close)
	current_screen.connect("focus_entered", _on_screen_focus_entered.bind(current_screen))
	
	# Show the new screen.
	add_child(current_screen)
	
	# Tell the screen it's now open.
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

func _on_screen_close() -> void:
	close_screen()

func _on_browser_open_file(path: String) -> void:
	if current_screen:
		return
	
	match path.get_extension():
		"json", "txt", "md", "csv", "xml", "ini", "confg", "toml":
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
	state_machine.send_message("start_moving_file", {
		# A new `File` is created because the original file will be freed when the 
		# list changed and items are removed.
		"file": File.new(file.path, file.is_directory)
	})
	
func _on_context_menu_duplicate(file: File) -> void:
	var new_file_name = FS.get_next_file_name(file.path)
	var base_directory = file.path.get_base_dir()
	
	FS.copy(file.path, base_directory + "/" + new_file_name)
	browser_screen.reload()
	browser_screen.file_list.focus_file_by_id(File.get_id_from_path(base_directory + "/" + new_file_name))
	
func _on_context_menu_trash(file: File) -> void:
	FS.trash(file.path)
	browser_screen.reload()
	
func _on_context_menu_closed() -> void:
	browser_screen.grab_focus()

	if current_screen:
		current_screen.grab_focus()
	
func _on_browser_show_options(file: File) -> void:
	if state_machine.current_state.name != "Default":
		return

	ContextMenu.show("Options for " + file.file_name, [
		{ "label": "Reload", "callback": func(): browser_screen.reload() },
		{ "label": "Move", "callback": _on_context_menu_move.bind(file) },
		{ "label": "Duplicate", "callback": _on_context_menu_duplicate.bind(file) },
		{ "label": "Rename", "callback": func(): print("rename!") },
		{ "label": "---" },
		{ "label": "Trash", "callback": _on_context_menu_trash.bind(file) },
	])

func _on_browser_select_current_directory(path: String) -> void:
	state_machine.send_message("move_to_directory", {
		"path": path
	})
	
func _on_browser_grab_file(file: File, strength: float) -> void:
	state_machine.send_message("grabbing_file", {
		"file": File.new(file.path, file.is_directory),
		"strength": strength
	})

func _on_browser_grab_ended() -> void:
	state_machine.send_message("stop_grabbing_file")
