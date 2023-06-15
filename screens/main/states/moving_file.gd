extends MainState

var file: File = null
var is_grabbing: bool = false

func enter(params: Dictionary) -> void:
	is_grabbing = params.get("grabbing", false)
	
	assert(params.has("file"), "File param required when transitioning to this state")
	
	file = params.file
	main.browser_screen.interaction_mode = main.browser_screen.InteractionMode.SELECT_DIRECTORY

	if is_grabbing:
		var item: FileItem = main.browser_screen.file_list.get_item_by_id(file.id)
		var item_viewport_texture = item.get_viewport().get_texture()
		
		var item_screenshot = TextureRect.new()
		item_screenshot.texture = item_viewport_texture
		item_screenshot.size = item.size
		print(item_screenshot)
		
		main.add_child(item_screenshot)
#		var tween = get_tree().create_tween()
#
#		tween.bind_node(item)
#		tween.tween_property(item, "rotation", deg_to_rad(1), 0.2)

		pass
	
func exit() -> void:
	file.queue_free()
	file = null

func handle_message(title: String, params: Dictionary) -> void:
	if is_grabbing and title == "stop_grabbing_file":
		perform_move()
		return

	if title == "move_to_directory":
		perform_move()
		return

func perform_move() -> void:
	if file.path.get_base_dir() == main.browser_screen.current_path:
		print("Already exists in this folder, cancelling move")
		
		main.browser_screen.file_list.focus_file(file)
		state_machine.transition_to("Default")
		return
	
	# TODO: Add error handling here with returned value.
	FS.move(file.path, main.browser_screen.current_path)

	main.browser_screen.reload()
	# TODO: Replace with path joining fuinction.
	main.browser_screen.file_list.focus_file_by_id(File.get_id_from_path(main.browser_screen.current_path + "/" + file.file_name))
	
	state_machine.transition_to("Default")
