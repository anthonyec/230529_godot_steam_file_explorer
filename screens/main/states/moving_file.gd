extends MainState

var file: File = null

func enter(params: Dictionary) -> void:
	assert(params.has("file"), "File param required when transitioning to this state")
	
	file = params.file
	main.browser_screen.interaction_mode = main.browser_screen.InteractionMode.SELECT_DIRECTORY
	
func exit() -> void:
	file.queue_free()
	file = null

func handle_message(title: String, params: Dictionary) -> void:
	if title == "move_to_directory":
		var path = params.get("path", null)
		assert(path, "Directory path required when moving file")
		
		if file.path.get_base_dir() == main.browser_screen.current_path:
			print("Already exists in this folder, cancelling move")
			
			main.browser_screen.file_list.focus_file(file)
			state_machine.transition_to("Default")
			return
		
		# TODO: Add error handling here with returned value.
		FS.move(file.path, path)

		main.browser_screen.reload()
		# TODO: Replace with path joining fuinction.
		main.browser_screen.file_list.focus_file_by_id(File.get_id_from_path(path + "/" + file.file_name))
		
		state_machine.transition_to("Default")
