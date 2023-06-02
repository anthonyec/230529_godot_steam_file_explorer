class_name Files
extends Control

signal item_focused(file: File)
signal item_selected(file: File)

@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var list: VBoxContainer = %List

var item_resource: Resource = preload("res://entities/files/file.tscn")
var empty_state_resource: Resource = preload("res://entities/files/empty_state.tscn")

var focused_index: int
var focused_file: File
var files: Array[File] = []
var action_button: Dictionary = {}

func set_files(new_files: Array[File]) -> void:
	files = new_files
	
	# Clear existing list.
	for item in list.get_children():
		list.remove_child(item)
		item.queue_free()
		
	if not action_button.is_empty():
		var button = Button.new()
		
		button.text = action_button.label
		button.connect("pressed", action_button.callback)
		list.add_child(button)
		
	if files.is_empty():
		var empty_state = empty_state_resource.instantiate()

		list.add_child(empty_state)
		focus_first_item()
		return
	
	var found_focused_item: FileItem = null
	
	# Create a new list.
	for index in files.size():
		var file = files[index]
		var item = item_resource.instantiate() as FileItem
		
		item.file = file
		item.file.index = index
		
		item.connect("focus_entered", _on_item_focused.bind(index, file, item))
		item.connect("pressed", _on_item_pressed.bind(file))
		
		if not action_button.is_empty() and not file.is_directory:
			item.disabled = true
			
		list.add_child(item)
		
		if focused_file and file.id == focused_file.id:
			found_focused_item = item

	if found_focused_item:
		found_focused_item.grab_focus()
		return
		
	focus_first_item()

func get_files() -> Array[File]:
	return files
	
func get_first_item() -> Button:
	return list.get_child(0) as Button
	
func get_focused_file() -> File:
	if focused_index < files.size():
		return files[focused_index]
	
	return null
	
func focus_first_item() -> void:
	var first_item = get_first_item()
	
	if first_item:
		first_item.grab_focus()
	
func scroll_into_view(item: Button) -> void:
	var item_rect = item.get_rect()
	var item_screen_position = item.get_screen_position()
	var scroll_rect = scroll_container.get_rect()
	var scroll_screen_position = scroll_container.get_screen_position()
	
	var item_bottom = item_screen_position.y + item_rect.size.y
	var scroll_view_bottom = scroll_screen_position.y + scroll_rect.size.y
	
	if item_screen_position.y < scroll_screen_position.y or item_bottom > scroll_view_bottom:
		# TODO: Take into account how much scrolling is left so that it scrolls 
		# smoothly to the end, instead of trying to scroll a fixed size.
		var new_scroll_position = item.position.y - (scroll_rect.size.y / 2)
		var scroll_tween = get_tree().create_tween()
		
		scroll_tween.tween_property(scroll_container, "scroll_vertical", new_scroll_position, 0.2) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_CIRC)
			
func enable_action_button(label: String, callback: Callable) -> void:
	action_button = {
		"label": label,
		"callback": callback
	}
	
func disable_action_button() -> void:
	action_button = {}

func _on_item_focused(index: int, file: File, item: Button) -> void:
	focused_index = index
	focused_file = file
	item_focused.emit(file)
	scroll_into_view(item)
	
func _on_item_pressed(file: File) -> void:
	item_selected.emit(file)
