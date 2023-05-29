extends Control

# TODO: Make dynamic to handle Windows?? : (
const DELIMITER = "/"
const ROOT_PATH = "/"

@export var current_path: String = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)

@onready var file_list: FileList = $FileList as FileList

func _ready() -> void:
	var files = get_directory_contents(current_path)
	
	file_list.set_items(files)
	
func goto(path: String) -> void:
	current_path = path
	
	var files = get_directory_contents(current_path)
	file_list.set_items(files)
	
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
		print("Failed dir_access")
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

func _on_file_list_file_selected(file: File) -> void:
	if file.is_directory:
		goto(get_child_path(current_path, file.file_name))

func _on_file_list_list_back() -> void:
	var new_path = get_parent_path(current_path)
	
	if new_path == ROOT_PATH:
		return
	
	goto(new_path)
