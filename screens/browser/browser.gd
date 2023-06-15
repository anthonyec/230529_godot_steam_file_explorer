class_name Browser
extends Screen

signal open_file(path: String)

# TODO: Make dynamic to handle Windows?? : (
const DELIMITER = "/"
const ROOT_PATH = "/"

enum InteractionMode {
	BROWSE,
	SELECT_DIRECTORY
}

@export var current_path: String = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/test_folder" 

@onready var file_list: Files = %Files as Files
@onready var go_up_button: Button = %GoUpButton
@onready var title_label: Label = %Title
@onready var path_label: Label = %Path
@onready var count_label: Label = %Count
@onready var directory_action_button: Button = %DirectoryActionButton
@onready var state_machine: StateMachine = $StateMachine as StateMachine

var is_changing_directory: bool = false
var was_grabbing: bool = false

func _ready() -> void:
	super()
	goto(current_path)
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel", true):
		_on_go_up_button_pressed()
	
	if event.is_action_released("options", true):
		show_file_options()
			
	if event.is_action_released("mark", true):
		var focused_file = file_list.focused_file
		
		if focused_file:
			focused_file.is_selected = !focused_file.is_selected
			SFX.play_everywhere("select")
		
func get_controls() -> Dictionary:
	return {
		"ui_cancel": {
			"label": "Back",
			"callback": func(): _on_go_up_button_pressed()
		},
		"options": {
			"label": "Options",
			"callback": func(): pass
		},
		"mark": {
			"label": "Select",
			"callback": func():
				var focused_file = file_list.focused_file
				focused_file.is_selected = !focused_file.is_selected
				SFX.play_everywhere("select") \
		},
		"ui_accept": {
			"label": "Open"
		}
	}
	
func show_file_options() -> void:
	if state_machine.current_state.name != "Default":
		return
	
	var focused_file = file_list.focused_file
		
	if not focused_file:
		return
	
	# A new `File` is created because the original file will be freed when 
	# the list changes and items are removed.
	var file = File.new(focused_file.path, focused_file.is_directory)
	
	ContextMenu.show("Options for " + file.file_name, [
		{ "label": "Reload", "callback": reload }, # TODO: Move this somewhere else, it's not file specfic!
		{ "label": "Move", "callback": move_file.bind(file) },
		{ "label": "Duplicate", "callback": duplicate_file.bind(file) },
		{ "label": "Rename", "callback": rename_file.bind(file) },
		{ "label": "---" },
		{ "label": "Trash", "callback": trash_file.bind(file) },
	])
	
func move_file(file: File) -> void:
	state_machine.send_message("move_file", {
		"file": file
	})
	
func duplicate_file(file: File) -> void:
	var new_file_name = FS.get_next_file_name(file.path)
	var base_directory = file.path.get_base_dir()
	
	FS.copy(file.path, base_directory + "/" + new_file_name)
	reload()
	file_list.focus_file_by_id(File.get_id_from_path(base_directory + "/" + new_file_name))
	
func rename_file(file: File) -> void:
	print("Implement: rename file")
	
func trash_file(file: File) -> void:
	FS.trash(file.path)
	reload()
	
func sort_files_by_kind(file_a: File, file_b: File) -> bool:
	if file_a.is_directory and not file_b.is_directory:
		return true
		
	return false
	
func sort_files_by_alphabetical(file_a: File, file_b: File) -> bool:
	return file_a.file_name < file_b.file_name
	
func open(path: String) -> void:
	open_file.emit(path)
	
func goto(path: String) -> void:
	current_path = path
	
	var directory_title = current_path.get_file()
	var files = get_directory_contents(current_path)
	var count = files.size()
	
	title_label.text = directory_title
	path_label.text = path
	count_label.text = str(count) + " files"
	files.sort_custom(sort_files_by_alphabetical)
	file_list.set_files(path, files)
	
func reload() -> void:
	goto(current_path)
	
func get_parent_path(path: String) -> String:
	var split = path.split("/")
	
	split.remove_at(split.size() - 1)
	
	var new_path = ""
	
	# TODO: Tidy this up, this is a messy cba way to do stuff.
	for segment in split:
		if new_path == "" and segment == "":
			new_path = DELIMITER
		elif new_path == "/":
			new_path += segment
		else:
			new_path += DELIMITER + segment
		
	return new_path
	
func get_child_path(path: String, child_path: String) -> String:
	return path + DELIMITER + child_path

func get_directory_contents(path: String) -> Array[File]:
	var dir_access = DirAccess.open(path)
	
#	dir_access.include_hidden = true
	
	if not dir_access:
		push_warning("Failed to access directory, could be empty.")
		return []
	
	# Begin scanning directory.
	dir_access.list_dir_begin()
	
	var contents: Array[File] = []
	var file_name = dir_access.get_next()
		
	while file_name != "":
		var full_path = dir_access.get_current_dir() + DELIMITER + file_name
		var new_file = File.new(full_path, dir_access.current_is_dir())
		
		# Add file to list.
		contents.append(new_file)
		
		# Move onto next file.
		file_name = dir_access.get_next()
	
	return contents
	
func into_animation() -> Signal:
	var tween = get_tree().create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(file_list, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(file_list, "modulate", Color(1, 1, 1, 0), 0.2).set_trans(Tween.TRANS_SINE)

	return tween.finished
	
func outo_animation() -> Signal:
	var tween = get_tree().create_tween()

	tween.set_parallel(true)
	tween.tween_property(file_list, "scale", Vector2(1, 1), 0.2).from(Vector2(0.9, 0.9)).set_trans(Tween.TRANS_SINE)
	tween.tween_property(file_list, "modulate", Color(1, 1, 1, 1), 0.2).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_SINE)
	
	return tween.finished
	
func _on_files_item_focused(_file: File) -> void:
	SFX.play_everywhere("highlight")

func _on_files_item_selected(file: File) -> void:
	if is_changing_directory:
		return
		
	if file.is_directory:
		SFX.play_everywhere("enter")
		
		is_changing_directory = true
		await into_animation()
		goto(file.path)
		await outo_animation()
		is_changing_directory = false
		
	else:
		open(file.path)

func _on_go_up_button_pressed() -> void:
	SFX.play_everywhere("back")
	
	var new_path = get_parent_path(current_path)
	
	if new_path == ROOT_PATH:
		return
	
	await into_animation()
	goto(new_path)
	await outo_animation()
	
func _on_files_changed(_paths) -> void:
	reload()
