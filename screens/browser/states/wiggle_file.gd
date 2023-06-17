extends BrowserState

var file: File = null
var strength: float = 0
var original_position: Vector2
var was_grabbing: bool = false

func enter(params: Dictionary) -> void:
	assert(params.has("file"), "File param required")
	file = params.file
	
	var item: FileItem = browser.file_list.get_item_by_id(file.id)
	original_position = item.position
	
	browser.grab_hand.appear()
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_released("grab", true) and was_grabbing:
		was_grabbing = false
		strength = 0
		grab_released()
		return
		
	if event.is_action_pressed("grab", true):
		was_grabbing = true
		strength = event.get_action_strength("grab", true)

func update(delta: float) -> void:
	if not file:
		return
		
	var item: FileItem = browser.file_list.get_item_by_id(file.id)
	
	if not item:
		state_machine.transition_to("Default")
		return
	
	item.position = original_position + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * 5
#	item.rotation_degrees = randf_range(-1, 1)

	if strength > 0.8 and state_machine.time_in_current_state > 100:
		state_machine.transition_to("MoveFile", {
			"file": file,
			"grabbing": true,
			"original_position": original_position
		})

func grab_released() -> void:
	print("grab released")
	
	var item: FileItem = browser.file_list.get_item_by_id(file.id)
	item.position = original_position
	
	state_machine.transition_to("Default")
