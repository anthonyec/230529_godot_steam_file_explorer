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
@onready var move_actions: HBoxContainer = %MoveActions
@onready var cancel_move_button: Button = %CancelMoveButton
@onready var move_to_folder_button: Button = %MoveToFolderButton
@onready var state_machine: StateMachine = $StateMachine as StateMachine
@onready var grab_hand: GrabHand = $GrabHand as GrabHand
@onready var sidebar: Sidebar = $Sidebar as Sidebar
@onready var panel: Panel = $Panel
 
var is_changing_directory: bool = false
var was_grabbing: bool = false

func _ready() -> void:
	super()
	goto(current_path)
	panel.connect("resized", _on_panel_resize)
	_on_panel_resize()
	
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
			
	if event.is_action_pressed("menu", true):
		sidebar.open()
		
func _on_panel_resize() -> void:
	panel.pivot_offset = panel.size / 2
	sidebar.size.y = get_viewport().size.y

func show_file_options() -> void:
	if state_machine.current_state.name != "Default":
		return
	
	# A new `File` is created because the original file will be freed when 
	# the list changes and items are removed e.g when moving files between directories.
	var files: Array[File] = File.new_from(file_list.get_selected_or_focused_files())
	
	if files.is_empty():
		return
	
	var is_multiple_files = files.size() > 1
	var menu_title = "Options for " + files[0].file_name
	
	if is_multiple_files:
		menu_title = "Options for " + str(files.size()) + " files"

	ContextMenu.show(menu_title, [
		# TODO: Move this somewhere else, it's not file specfic!
		{ "label": "Reload", "callback": reload },
		{ "label": "Move", "callback": move_file.bind(files) },
		{ "label": "Duplicate", "callback": duplicate_file.bind(files) },
		{ "label": "Rename", "callback": rename_file.bind(files[0]), "hidden": is_multiple_files },
		{ "label": "---" },
		{ "label": "Trash", "callback": trash_file.bind(files) },
	], self)
	
func move_file(files: Array[File]) -> void:
	state_machine.send_message("move_files", {
		"files": files
	})
	
func duplicate_file(files: Array[File]) -> void:
	var copy_arguments: Array = [];
	
	for file in files:
		var new_file_name = FileSystemProxy.get_next_file_name(file.path)
		var base_directory = file.path.get_base_dir()
		FileSystemProxy.copy(file.path, base_directory + "/" + new_file_name)
	
	reload()
	
#	file_list.focus_file_by_id(File.get_id_from_path(copy_arguments[0][1]))
	file_list.unselect_all()

	
func rename_file(file: File) -> void:
	var keyboard_parameters = Keyboard.Parameters.new()
	
	keyboard_parameters.placeholder = "Enter file name"
	keyboard_parameters.value = file.file_name
	keyboard_parameters.multiline = false
	
	keyboard_parameters.confirmed.connect(func(new_file_name: String):
		var base_path = file.path.get_base_dir()
		
		if new_file_name.strip_edges() == "":
			push_warning("Not moving, new name is blank")
			return
		
		FS.rename(file.path, new_file_name)
		
		reload()
		file_list.focus_file_by_id(File.get_id_from_path(base_path + "/" + new_file_name))
	)
	
	keyboard_parameters.cancelled.connect(func():
		print("Cancelled")
	)
	
	Keyboard.present(keyboard_parameters, self)

func trash_file(files: Array[File]) -> void:
	for file in files:
		FileSystemProxy.trash(file.path)

	reload()
	file_list.unselect_all()
	
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
	var entries = FileSystemProxy.get_directory_entries(path)
	var contents: Array[File] = []
	
	for entry in entries:
		var new_file = File.new_from_entry(entry)
		contents.append(new_file)
	
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
