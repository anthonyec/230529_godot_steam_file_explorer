extends BrowserState

const OFFSET: Vector2 = Vector2(2, 3) 

var FilePlaceholder: PackedScene = preload("res://components/file_placeholder/file_placeholder.tscn")

var files: Array[File] = []
var cancelled: bool = false
var grabbed_placeholders: Array[FilePlaceholder] = []

func awake() -> void:
	super()
	browser.move_to_folder_button.connect("pressed", _on_move_to_folder_button_pressed)
	browser.cancel_move_button.connect("pressed", _on_cancel_move_button_pressed)

func enter(params: Dictionary) -> void:
	assert(params.has("files"), "The `files` param is required")
	files = params.get("files")
	cancelled = false
	
	browser.move_actions.visible = true
	browser.grab_hand.appear()
	
	var placeholders: Array[FilePlaceholder] = []
	
	# Create placeholder items.
	for file in files:
		var item = browser.file_list.get_item_by_id(file.id)
		var rect = item.get_global_rect()
		var file_placeholder = FilePlaceholder.instantiate() as FilePlaceholder
		
		file_placeholder.size = rect.size
		file_placeholder.position = rect.position
		file_placeholder.file = file
		
		browser.add_child(file_placeholder)
		placeholders.append(file_placeholder)
		
	# Reversed so that the items nearer the bottom of the screen animate first.
	placeholders.reverse()
	
	# Animate placeholder items to hand.
	for index in placeholders.size():
		var placeholder = placeholders[index]
		var tween = placeholder.create_tween()
		var end_position = browser.grab_hand.end_position + OFFSET * index
		
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(placeholder, "position", end_position, 0.3)
		tween.tween_property(placeholder, "size", Vector2(120, 50), 0.3)
		tween.tween_property(placeholder, "rotation", deg_to_rad(1 * -index), 0.3)
		
		# Stagger animation between each placeholder.
		await tween.tween_interval(0.1).finished
		
		tween.connect("finished", _on_placeholder_enter_tween_finished.bind(placeholder))
		
		# Wait for last item to finish it's tween before exiting loop.
		if index == placeholders.size() - 1:
			await tween.finished

func exit() -> void:
	browser.move_actions.visible = false
	
	var index = grabbed_placeholders.size() - 1
	
	while index >= 0:
		var placeholder = grabbed_placeholders[index]
		
		# Remove placeholder list so that it can be animated, and isn't 
		# positioned where the hand is in `update`.
		grabbed_placeholders.remove_at(index)
		
		var tween = placeholder.create_tween()
		var file_id = File.get_id_from_path(browser.current_path + "/" + placeholder.file.file_name)
		var item = browser.file_list.get_item_by_id(file_id)
		
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		
		# If no item is found in the list, do a generic fade out.
		if item == null or cancelled:
			tween.tween_property(placeholder, "position", placeholder.position - Vector2(0, 80), 0.3)
			tween.tween_property(placeholder, "modulate", Color(1, 1, 1, 0), 0.3)
			tween.tween_property(placeholder, "scale", Vector2(1.1, 1.1), 0.3)
			
		# Otherwise animate them to the size and position in the list.
		else:
			var rect = item.get_global_rect()
			tween.tween_property(placeholder, "position", rect.position, 0.3)
			tween.tween_property(placeholder, "size", rect.size, 0.3)
			tween.tween_property(placeholder, "rotation", 0, 0.3)
		
		tween.connect("finished", _on_placeholder_exit_tween_finished.bind(placeholder))
		
		# Only stagger animation if items exist in list.
		if item != null or cancelled:
			# TODO: Find out why this does not work well with lower values than 0.1.
			await tween.tween_interval(0.1).finished
		
		# Wait for last item to finish it's tween before exiting loop.
		# TODO: Can this be replaced with `WaitGroup`?
		if index == 0:
			await tween.finished
		
		index -= 1
	
	browser.grab_hand.disappear()

func update(_delta: float) -> void:
	# Once a placeholder has been animated, is it then always positioned where the hand is.
	for index in grabbed_placeholders.size():
		var placeholder = grabbed_placeholders[index]
		placeholder.position = browser.grab_hand.position + OFFSET * index

func move_files() -> int:
	for file in files:
		var result = FileSystemProxy.move(file.path, browser.current_path)
		
		if result != 0:
			return result
		
		# Make file invisible while the placeholder is animated into place.
		var id := File.get_id_from_path(browser.current_path + "/" + file.file_name)
		browser.file_list.set_invisible_file(id)
	
	browser.reload()
	await browser.file_list.animations_finished
	return 0
	
func _on_placeholder_enter_tween_finished(placeholder: FilePlaceholder) -> void:
	grabbed_placeholders.append(placeholder)
	browser.grab_hand.push(Vector2(1, 1))

func _on_placeholder_exit_tween_finished(placeholder: FilePlaceholder) -> void:
	var tween = placeholder.create_tween()
	
	# Show the file once the placeholder animation is finished.
	var id := File.get_id_from_path(browser.current_path + "/" + placeholder.file.file_name)
	browser.file_list.set_visible_file(id)
	
	# Fade out and remove.
	tween.tween_property(placeholder, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween.finished
	browser.remove_child(placeholder)
	
func _on_move_to_folder_button_pressed() -> void:
	var result = await move_files()
	
	if result != 0:
		print("Failed to move files!")
		return
		
	state_machine.transition_to("Default")
	
func _on_cancel_move_button_pressed() -> void:
	cancelled = true
	state_machine.transition_to("Default")
