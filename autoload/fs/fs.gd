extends Node

enum MoveError {
	FILE_OR_DIRECTORY_DOES_NOT_EXIST
}

class Entry:
	var file_name: String
	var file_name_without_extension: String
	var path: String
	var extension: String
	var is_directory: bool
	var is_deleted: bool
	var is_transient: bool
	var size: int

var duplicate_regex = RegEx.new()

func _ready() -> void:
	duplicate_regex.compile("\\scopy(\\s\\d+)?$")
	
func is_supported_os(os_names: Array[String], unsupported_action: String = "") -> bool:
	var is_suporrted = os_names.has(OS.get_name().to_lower())
	
	if not is_suporrted and unsupported_action:
		push_error(unsupported_action + " is not supported in " + OS.get_name())
	
	return is_suporrted

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
	if not is_supported_os(["linux", "macos"], "trash"):
		return
		
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

func get_directory_entries(path: String) -> Array[FS.Entry]:
	var dir_access = DirAccess.open(path)
	
	if not dir_access:
		push_error("Failed to get entries for: ", path)
		return []
		
	dir_access.list_dir_begin()
	
	var file_sizes = get_file_sizes(path)
	var file_name = dir_access.get_next()
	
	var results: Array[FS.Entry] = []
		
	while file_name != "":
		var file_path = path + "/" + file_name
		var file_size = file_sizes.get(file_path, 0)
		
		var entry = FS.Entry.new()
		
		entry.file_name = file_name
		entry.file_name_without_extension = get_file_name_without_extension(file_path)
		entry.path = file_path
		entry.extension = file_name.get_extension()
		entry.size = file_size
		entry.is_directory = is_directory(file_path)
		
		results.append(entry)
		file_name = dir_access.get_next()
		
	return results
	
func get_file_sizes(path: String) -> Dictionary:
	# TODO: Disabled because the `du` command recursively scans directories
	# to find out sizes which causes this to hang. Maybe there's a better way 
	# with using C++ and system native API in GDExtension to get directory 
	# apparent sizes. Or maybe this can be run for files only, excluding dirs?
	return {}
	
	if not is_supported_os(["linux", "macos"], "get_file_sizes"):
		return {}
		
	var output: Array = []
	var arguments = [
		# Use apparent size.
		"-A", 
		# Display block counts in 1024-byte (1 kiB) blocks.
		"-k", 
		# Only list files without recursing. 
		"-d 1",
		path
	]
	var exit_code = OS.execute("du", arguments, output, true)
	
	if exit_code != 0 or output.is_empty():
		push_error("Failed to get file sizes")
		return {}
		
	var list: String = output[0]
	var lines = list.split("\n")
	var results = {}
	
	for line in lines:
		var columns = line.split("\t")
		
		if columns.size() < 2:
			continue
		
		var size_as_string: String = columns[0]
		var file_path: String = columns[1]
		
		if size_as_string.strip_edges() != "":
			results[file_path] = int(size_as_string)
			
	return results
	
func get_file_name_without_extension(path: String) -> String:
	var file_name = path.get_file()
	var extension = file_name.get_extension()
	
	return file_name.trim_suffix("." + extension)
	
func get_extension(path: String, include_period: bool = false) -> String:
	var extension = path.get_extension()
	
	if extension and include_period:
		return "." + extension
	
	return extension
