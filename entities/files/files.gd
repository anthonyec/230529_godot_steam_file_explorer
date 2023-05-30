class_name Files
extends Control

signal item_focused(file: File)
signal item_selected(file: File)

@onready var list: VBoxContainer = $ScrollContainer/List

var item_resource: Resource = preload("res://entities/files/file.tscn")
var empty_state_resource: Resource = preload("res://entities/files/empty_state.tscn")

var focused: int = 0
var files: Array[File] = []

func set_files(new_files: Array[File]) -> void:
	files = new_files
	
	# Clear existing list.
	for item in list.get_children():
		list.remove_child(item)
		
	if files.is_empty():
		var empty_state = empty_state_resource.instantiate()
		
		list.add_child(empty_state)
		return
	
	# Create a new list.
	for index in files.size():
		var file = files[index]
		var item = item_resource.instantiate() as Button
		
		item.text = file.file_name
		item.connect("focus_entered", _on_item_focused.bind(index, file))
		item.connect("pressed", _on_item_pressed.bind(file))
		
		list.add_child(item)
		
	var first_item = get_first_item()
	
	if first_item:
		first_item.grab_focus()

func get_files() -> Array[File]:
	return files
	
func get_first_item() -> Button:
	return list.get_child(0) as Button

func _on_item_focused(index: int, file: File) -> void:
	focused = index
	item_focused.emit(file)
	
func _on_item_pressed(file: File) -> void:
	item_selected.emit(file)
