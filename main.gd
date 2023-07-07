class_name Main
extends Control

@onready var browser_screen: Browser = %Browser as Browser
@onready var status_bar: StatusBar = %StatusBar as StatusBar
@onready var debug_console: TextEdit = %DebugConsole

var current_screen: Window = null

func _ready() -> void:
	var init: Dictionary = Steam.steamInit(false)
	
	print(init);
	
	debug_console.text += "Steam ID: " + str(Steam.getSteamID())
	
	await get_tree().create_timer(5).timeout
	
	Steam.showGamepadTextInput(Steam.GAMEPAD_TEXT_INPUT_MODE_NORMAL, Steam.GAMEPAD_TEXT_INPUT_LINE_MODE_SINGLE_LINE, "Rename file", 256, "File name")
	
#	await get_tree().create_timer(10).timeout
#
#	debug_console.text += "Show overlay"
#
#	Steam.activateGameOverlayToWebPage("https://google.com")
	
	
func _process(_delta: float) -> void:
	Steam.run_callbacks()

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
