extends Node

enum MoveError {
	FILE_OR_DIRECTORY_DOES_NOT_EXIST
}

var duplicate_regex = RegEx.new()

func _ready() -> void:
	duplicate_regex.compile("\\scopy(\\s\\d+)?$")

# Create a unique directory to access and store temporary files.
func create_temporary_directory() -> DirAccess:
	var timestamp = Time.get_unix_time_from_system()
	var random_number = randf()
	
	var generated_name = str(random_number) + str(timestamp)
	var hashed_generated_name = generated_name.md5_text()
	var temp_path = "temp/" + hashed_generated_name
	
	var dir_access = DirAccess.open("user://")
	
	if not dir_access:
		push_error("Failed to create temporary directory: ", temp_path)
		return null
	
	dir_access.make_dir_recursive(temp_path)
	dir_access.change_dir(temp_path)
	
	return dir_access

# Move a directory or file to the system's trash bin.
func trash(path: String) -> void:
	if OS.get_name() == "Linux":
		var output: Array = []
		var exit_code = OS.execute("gio", ["trash", path], output, true)
	
		if exit_code != 0:
			push_error("Failed to trash: ", output)
			
	if OS.get_name() == "macOS":
		var output: Array = []
		var arguments = [ProjectSettings.globalize_path("res://autoload/fs/trash.scpt"), path]
		var exit_code = OS.execute("osascript", arguments, output, true)
	
		if exit_code != 0:
			push_error("Failed to trash: ", output)

# Move a directory or file.
# TODO: Return an erro result.
func move(from: String, to: String) -> void:
	var output: Array = []
	var exit_code = OS.execute("mv", [from, to], output, true)
	
	if exit_code != 0:
		push_error("Failed to move: ", output)
		
func rename(path: String, new_file_name: String) -> void:
	var base_path = path.get_base_dir()
	move(path, base_path + "/" + new_file_name)

# TODO: Return an error result.
# TODO: Make asynchronous? Or a FS.add_task for threads?
func copy(from: String, to: String) -> void:
	var output: Array = []
	var arguments: Array[String] = [from, to]
	
	if is_directory(from):
		arguments.push_front("-R")

	var exit_code = OS.execute("cp", arguments, output, true)
	
	if exit_code != 0:
		push_error("Failed to copy: ", output)
		
func is_directory(path: String) -> bool:
	var dir_access = DirAccess.open(path)
	
	if dir_access:
		return true
	
	return false

# Check if file or directory exists.
func exists(path: String) -> bool:
	var base_directory = path.get_base_dir()
	var file = path.get_file()
	var dir_access = DirAccess.open(base_directory)
	
	if not dir_access:
		return false
	
	if dir_access.file_exists(file):
		return true
		
	if dir_access.dir_exists(file):
		return true
	
	return false

# Return an array of names for files and folders in the directory. It's *not* a
# recusrive scan, and only lists the direct children.
func get_files_in_directory(path: String) -> Array[String]:
	var dir_access = DirAccess.open(path)
	
	dir_access.list_dir_begin()
	
	var file_names: Array[String] = []
	var file_name = dir_access.get_next()
		
	while file_name != "":
		file_names.append(file_name)
		file_name = dir_access.get_next()
		
	return file_names
	
func get_file_name_without_extension(path: String) -> String:
	var file_name = path.get_file()
	var extension = file_name.get_extension()
	
	return file_name.trim_suffix("." + extension)
	
func get_extension(path: String, include_period: bool = false) -> String:
	var extension = path.get_extension()
	
	if extension and include_period:
		return "." + extension
	
	return extension

# TODO: Reword this description. The behaviour is like macOS.
# Returns a file name with "copy" appened. If a file already exists with "copy" 
# at the end, then it keeps incrementing a number suffix until one does not exist.
# E.g "file copy.png", "file copy 2.png", "file copy 3.png" etc.
func get_next_file_name(path: String) -> String:
	var base_directory = path.get_base_dir()
	var plain_name = get_file_name_without_extension(path)
	var extension = get_extension(path, true)
	
	var copy_suffix = duplicate_regex.search(plain_name)
	var name_without_suffix = duplicate_regex.sub(plain_name, "")
	var tries: int = 2
#
	if copy_suffix:
		var count = int(copy_suffix.get_string(1).strip_edges())
		
		if count != 0:
			tries = count

	var new_file_name = name_without_suffix + " copy" + extension

	while exists(base_directory + "/" + new_file_name):
		new_file_name = name_without_suffix + " copy " + str(tries) + extension
		tries += 1
	
	return new_file_name
