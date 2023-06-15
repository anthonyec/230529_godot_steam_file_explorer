extends MainState

func enter(_params: Dictionary) -> void:
	main.browser_screen.interaction_mode = main.browser_screen.InteractionMode.BROWSE
	
func exit() -> void:
	pass

func handle_message(title: String, params: Dictionary) -> void:
	if title == "start_moving_file":
		assert(params.has("file"), "File required as a start_moving_file param")
		
		state_machine.transition_to("MoveFile", {
			"file": params.file
		})
		return
		
	if title == "grabbing_file":
		assert(params.has("file"), "File required as a start_moving_file param")
		
		state_machine.transition_to("WiggleFile", {
			"file": params.file
		})
		return
