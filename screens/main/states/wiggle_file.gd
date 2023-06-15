extends MainState

var file: File = null
var strength: float = 0
var original_position: Vector2

func enter(params: Dictionary) -> void:
	assert(params.has("file"), "File param required when transitioning to this state")
	file = params.file
	
	var item: FileItem = main.browser_screen.file_list.get_item_by_id(file.id)
	original_position = item.position
	
func exit() -> void:
	var item: FileItem = main.browser_screen.file_list.get_item_by_id(file.id)
	item.position = original_position

func update(delta: float) -> void:
	if strength > 0.8 and state_machine.time_in_current_state > 100:
		state_machine.transition_to("MoveFile", { "file": file, "grabbing": true })
		return
	
	var item: FileItem = main.browser_screen.file_list.get_item_by_id(file.id)
	
	if not item:
		state_machine.transition_to("Default")
		return
	
#	item.rotation_degrees = randf_range(-1, 1)
	item.position = original_position + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * 5
	
func handle_message(title: String, params: Dictionary) -> void:
	if title == "grabbing_file":
		assert(params.has("strength"))
		strength = params.strength
		
	if title == "stop_grabbing_file":
		state_machine.transition_to("Default")
		return
