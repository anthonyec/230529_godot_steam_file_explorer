extends BrowserState

var was_grabbing: bool = false

func enter(_params: Dictionary) -> void:
	browser.directory_action_button.visible = false
	browser.grab_hand.disappear()
	
func exit() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_released("grab", true) and was_grabbing:
		was_grabbing = false
		return
		
	if event.is_action_pressed("grab", true):
		var focused_file = browser.file_list.focused_file
		
		if not focused_file:
			return
		
		was_grabbing = true
			
		var file = File.new(focused_file.path, focused_file.is_directory)

		state_machine.transition_to("WiggleFile", {
			"file": file
		})

func handle_message(title: String, params: Dictionary) -> void:
	if title == "move_file":
		assert(params.has("file"), "File required as a start_moving_file param")
		
		state_machine.transition_to("MoveFile", {
			"file": params.file
		})
		return
