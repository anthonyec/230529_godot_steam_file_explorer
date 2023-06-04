extends Node

# If the path contains "user://", resolve it to the absolute path.
func resolve_user_path(path: String) -> String:
	if path.begins_with("user://"):
		var user_path = OS.get_user_data_dir()
		
		path = path.trim_prefix("user://")
		path = user_path + "/" + path
		
	return path

func create_temporary_directory() -> DirAccess:
	var timestamp = Time.get_unix_time_from_system()
	var seed = randf()
	
	var name = str(seed) + str(timestamp)
	var hash = name.md5_text()
	var temp_path = "temp/" + hash
	
	var dir_access = DirAccess.open("user://")
	
	if not dir_access:
		push_error("Failed to create temporary directory: ", temp_path)
		return null
	
	dir_access.make_dir_recursive(temp_path)
	dir_access.change_dir(temp_path)
	
	return dir_access

# Move a direcotry or file.
func move(from: String, to: String) -> void:
	var output: Array = []
	var exit_code = OS.execute("mv", [from, to], output, true)
	
	if exit_code != 0:
		push_error("Failed to move: ", output)
		
func get_file_names_in_directory(path: String) -> Array[String]:
	var dir_access = DirAccess.open(path)
	
	dir_access.list_dir_begin()
	
	var file_names: Array[String] = []
	var file_name = dir_access.get_next()
		
	while file_name != "":
		file_names.append(file_name)
		file_name = dir_access.get_next()
		
	return file_names

func create_shallow_directory_watcher(path: String) -> void:
	var file_names = get_file_names_in_directory(path)
	
#	var timer = get_tree().create_timer(1)
