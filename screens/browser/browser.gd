class_name Browser
extends Screen

signal open_file(path: String)
signal show_options(file: File)
signal select_current_directory(path: String)

# TODO: Make dynamic to handle Windows?? : (
const DELIMITER = "/"
const ROOT_PATH = "/"

enum InteractionMode {
	BROWSE,
	SELECT_DIRECTORY
}

@export var current_path: String = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/test_folder" 
@export var interaction_mode: InteractionMode:
	set = set_interaction_mode

@onready var file_list: Files = %Files as Files
@onready var go_up_button: Button = %GoUpButton
@onready var title_label: Label = %Title
@onready var path_label: Label = %Path
@onready var count_label: Label = %Count
@onready var directory_action_button: Button = %DirectoryActionButton

var watcher = DirectoryWatcher.new()

func _ready() -> void:
	super()
	directory_action_button.visible = false
	goto(current_path)
	
	add_child(watcher)
	watcher.files_created.connect(_on_files_changed)
	watcher.connect("files_modified", _on_files_changed)
	watcher.connect("files_deleted", _on_files_changed)
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel", true):
		_on_go_up_button_pressed()
	
	if event.is_action_released("options", true):
		var focused_file = file_list.focused_file
		
		if focused_file:
			show_options.emit(focused_file)
			
	if event.is_action_released("mark", true):
		var focused_file = file_list.focused_file
		focused_file.is_selected = !focused_file.is_selected
		
		SFX.play_everywhere("select")

func set_interaction_mode(value: InteractionMode) -> void:
	interaction_mode = value               
	
	if interaction_mode == InteractionMode.SELECT_DIRECTORY:
		directory_action_button.visible = true
		directory_action_button.text = "Move to this folder"
		file_list.enabled_files = "directories"
	else:
		directory_action_button.visible = false
		file_list.enabled_files = "all"
	
func sort_files_by_kind(file_a: File, file_b: File) -> bool:
	if file_a.is_directory and not file_b.is_directory:
		return true
		
	return false
	
func sort_files_by_alphabetical(file_a: File, file_b: File) -> bool:
	return file_a.file_name < file_b.file_name
	
func open(path: String) -> void:
	open_file.emit(path)
	
func goto(path: String) -> void:
	var old_path = current_path
	
	current_path = path
	
	var directory_title = current_path.get_file()
	var files = get_directory_contents(current_path)
	var count = files.size()
	
	title_label.text = directory_title
	path_label.text = path
	count_label.text = str(count) + " files"
	files.sort_custom(sort_files_by_alphabetical)
	file_list.set_files(path, files)
	
	watcher.add_scan_directory(current_path)
	
	if old_path != current_path:
		watcher.remove_scan_directory(old_path)
	
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
		var new_file = File.new()
		var full_path = dir_access.get_current_dir() + DELIMITER + file_name
		
		new_file.id = full_path.md5_text()
		new_file.file_name = file_name
		new_file.extension = file_name.get_extension()
		new_file.path = full_path
		new_file.is_directory = dir_access.current_is_dir()
		
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
	if file.is_directory:
		SFX.play_everywhere("enter")
		
		await into_animation()
		goto(file.path)
		await outo_animation()
		
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

func _on_directory_action_button_pressed() -> void:
	select_current_directory.emit(current_path)
	
func _on_files_changed(_paths: Array[String]) -> void:
	reload()
