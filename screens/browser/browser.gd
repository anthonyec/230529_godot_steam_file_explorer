extends Control

# TODO: Make dynamic to handle Windows?? : (
const DELIMITER = "/"
const ROOT_PATH = "/"

@export var current_path: String = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)

@onready var file_list: Files = %Files as Files
@onready var go_up_button: Button = %GoUpButton as Button

func _ready() -> void:
	goto(current_path)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		var focused_file = file_list.get_focused_file()
		_on_files_item_selected(focused_file)

	if Input.is_action_just_pressed("back"):
		_on_go_up_button_pressed()
	
func read_zip_file(path: String) -> void:
	var reader := ZIPReader.new()
	var error := reader.open(path)
	
	if error != OK:
		return PackedByteArray()
	
	var files = reader.get_files()
	
	print(files)
	
	reader.close()

func sort_files_by_kind(file_a: File, file_b: File) -> bool:
	if file_a.is_directory and not file_b.is_directory:
		return true
		
	return false
	
func sort_files_by_alphabetical(file_a: File, file_b: File) -> bool:
	return file_a.file_name < file_b.file_name
	
func open(path: String) -> void:
	var extension = path.get_extension()
	
	if extension == "zip":
		read_zip_file(path)
		print("Extract?")
	
func goto(path: String) -> void:
	current_path = path
	
	var files = get_directory_contents(current_path)
	
	files.sort_custom(sort_files_by_alphabetical)
	file_list.set_files(files)
	
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
	
	if not dir_access:
		push_warning("Failed to access directory, could be empty.")
		return []
	
	# Begin scanning directory.
	dir_access.list_dir_begin()
	
	var contents: Array[File] = []
	var file_name = dir_access.get_next()
		
	while file_name != "":
		var new_file = File.new()
		
		new_file.file_name = file_name
		new_file.is_directory = dir_access.current_is_dir()
		
		# Add file to list.
		contents.append(new_file)
		
		# Move onto next file.
		file_name = dir_access.get_next()
	
	return contents
	
func _on_files_item_focused(file: File) -> void:
	SFX.play_everywhere("highlight")

func _on_files_item_selected(file: File) -> void:
	if file.is_directory:
		goto(get_child_path(current_path, file.file_name))
		SFX.play_everywhere("enter")
	else:
		open(get_child_path(current_path, file.file_name))
		SFX.play_everywhere("invalid")

func _on_go_up_button_pressed() -> void:
	SFX.play_everywhere("back")
	
	var new_path = get_parent_path(current_path)
	
	if new_path == ROOT_PATH:
		return
	
	goto(new_path)
