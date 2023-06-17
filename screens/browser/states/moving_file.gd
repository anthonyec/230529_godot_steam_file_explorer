extends BrowserState

var file: File = null
var is_grabbing: bool = false
var was_grabbing: bool = true
var item_is_grabbed: bool = false
var item_screenshot: TextureRect

func enter(params: Dictionary) -> void:
	assert(params.has("file"), "File param required when transitioning to this state")
	file = params.file
	
	browser.directory_action_button.visible = true
	browser.directory_action_button.text = "Move to this folder"
	browser.directory_action_button.connect("pressed", perform_move)
	
	is_grabbing = params.get("grabbing", false)
	
	browser.grab_hand.appear()
	
	var item: FileItem = browser.file_list.get_item_by_id(file.id)
	var item_rect = item.get_global_rect()
	var image = get_viewport().get_texture().get_image().get_region(item_rect)
	var texture = ImageTexture.create_from_image(image)
	
	item_screenshot = TextureRect.new()
	item_screenshot.texture = texture
	item_screenshot.size = item.size
	item_screenshot.position = item.global_position
	
	browser.add_child(item_screenshot)
	
	var tween = get_tree().create_tween()
	
	tween.bind_node(item_screenshot)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_parallel(true)
	tween.tween_property(item_screenshot, "position", browser.grab_hand.end_position, 0.25)
	tween.tween_property(item_screenshot, "scale", Vector2(0.5, 0.5), 0.25)
	
	await tween.finished
	
	browser.grab_hand.push()
	item_is_grabbed = true
	
func exit() -> void:
	item_is_grabbed = false
	
	browser.directory_action_button.visible = false
	browser.directory_action_button.disconnect("pressed", perform_move)
	
	file.queue_free()
	file = null
	
	item_screenshot.queue_free()
	
func _process(delta: float) -> void:
	if item_is_grabbed:
		item_screenshot.position = browser.grab_hand.position
	
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