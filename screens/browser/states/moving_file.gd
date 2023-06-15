extends BrowserState

var file: File = null
var is_grabbing: bool = false
var was_grabbing: bool = true

func enter(params: Dictionary) -> void:
	assert(params.has("file"), "File param required when transitioning to this state")
	file = params.file
	
	browser.directory_action_button.visible = true
	browser.directory_action_button.text = "Move to this folder"
	browser.directory_action_button.connect("pressed", perform_move)
	
	is_grabbing = params.get("grabbing", false)

	if is_grabbing:
		var item: FileItem = browser.file_list.get_item_by_id(file.id)
		var item_viewport_texture = item.get_viewport().get_texture()
		
		var item_screenshot = TextureRect.new()
		item_screenshot.texture = item_viewport_texture
		item_screenshot.size = item.size
		print(item_screenshot)
		
		browser.add_child(item_screenshot)
	
func exit() -> void:
	browser.directory_action_button.visible = false
	browser.directory_action_button.disconnect("pressed", perform_move)
	
	file.queue_free()
	file = null
	
func handle_input(event: InputEvent) -> void:
	if not is_grabbing:
		return
		
	if event.is_action_released("grab", true) and was_grabbing:
		was_grabbing = false
		perform_move()
		return
		
	if event.is_action_pressed("grab", true):
		was_grabbing = true

func perform_move() -> void:
	if file.path.get_base_dir() == browser.current_path:
		print("Already exists in this folder, cancelling move")
		
		browser.file_list.focus_file(file)
		state_machine.transition_to("Default")
		return
	
	# TODO: Add error handling here with returned value.
	FS.move(file.path, browser.current_path)

	browser.reload()
	# TODO: Replace with path joining fuinction.
	browser.file_list.focus_file_by_id(File.get_id_from_path(browser.current_path + "/" + file.file_name))
	state_machine.transition_to("Default")
