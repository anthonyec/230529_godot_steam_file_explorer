class_name Files
extends Control

signal item_focused(file: File)
signal item_selected(file: File)

@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var list: VBoxContainer = %List
@onready var empty_state: CenterContainer = %EmptyState

@export var enabled_files: String:
	set = set_enabled_files

var item_resource: Resource = preload("res://components/files/file.tscn")

var focused_file: File
var files: Array[File] = []

var list_id: String = ""
var id_to_item_map: Dictionary = {}

func _ready() -> void:
	get_viewport().connect("gui_focus_changed", _on_gui_focus_changed)
	
func _on_gui_focus_changed(control: Control) -> void:
	if control.get_parent() == list:
		control = control as FileItem
		focused_file = control.file
		item_focused.emit(control.file)
		scroll_into_view(control)
	else: 
		focused_file = null

func set_enabled_files(value: String) -> void:
	enabled_files = value
	
	if value == "all":
		for file in files:
			file.is_disabled = false
		
	if value == "directories":
		for file in files:
			file.is_disabled = not file.is_directory
			
func create_item(file: File) -> FileItem:
	var item = item_resource.instantiate() as FileItem
	
	item.file = file
	
	item.connect("pressed", _on_item_pressed.bind(file))
	
	return item
	
func add_item(item: FileItem, index: int = -1) -> void:
	list.add_child(item)
	id_to_item_map[item.file.id] = item
	
	if index != -1:
		list.move_child(item, index)
	
func remove_item(item: FileItem) -> void:
	list.remove_child(item)
	id_to_item_map.erase(item.file.id)
	
func has_item_by_id(id: String) -> bool:
	return id_to_item_map.has(id)
	
func get_item_by_id(id: String) -> FileItem:
	return id_to_item_map[id]

func set_files(id: String, new_files: Array[File]) -> void:
	empty_state.visible = new_files.is_empty()
		
	# Blast away the whole list and start again if the ID has changed. This is
	# so it does not animate between directory changes, where every file would 
	# be new.
	if list_id != id:
		list_id = id
		
		for child in list.get_children():
			remove_item(child)
			
		for file in new_files:
			var item = create_item(file)
			add_item(item)
		
		focus_first_item()
		return
	
	var file_ids: Dictionary = {}
	
	for index in new_files.size():
		var new_file = new_files[index]
		var item_exists = has_item_by_id(new_file.id)
		
		if not item_exists:
			var item = create_item(new_file)
			add_item(item, index)
			
			var target_size = item.custom_minimum_size
			var tween = get_tree().create_tween()
			
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_EXPO)
			tween.set_parallel(true)
			tween.tween_property(item, "modulate", Color(1, 1, 1, 1), 0.3).from(Color(1, 1, 1, 0))
			tween.tween_property(item, "custom_minimum_size:y", target_size.y, 0.3).from(0)
			
		file_ids[new_file.id] = true
	
	var children_to_remove: Array[FileItem] = []
	
	for index in list.get_child_count():
		var item = list.get_child(index) as FileItem
		
		if not item:
			continue

		if not file_ids.has(item.file.id):
			children_to_remove.append(item)

	## TODO: Can avoid additional loop I think by making the above loop reversed.
	for child in children_to_remove:
		var tween = get_tree().create_tween()
		
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(child, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.tween_property(child, "custom_minimum_size:y", 0, 0.3)
		tween.tween_callback(func():
			remove_item(child)
		)
	
func get_first_item() -> FileItem:
	if list.get_child_count() == 0:
		return null
		
	return list.get_child(0) as FileItem
	
func focus_first_item() -> void:
	var first_item = get_first_item()
	
	if first_item:
		first_item.grab_focus()
		
func focus_file(file: File) -> void:
	if has_item_by_id(file.id):
		focus_file_by_id(file.id)
		
func focus_file_by_id(id: String) -> void:
	if has_item_by_id(id):
		get_item_by_id(id).grab_focus()
	
func scroll_into_view(item: FileItem) -> void:
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
	
func _on_item_pressed(file: File) -> void:
	item_selected.emit(file)
