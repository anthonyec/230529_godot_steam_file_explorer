extends Node

enum MoveError {
	NONE = 0,
	FILE_ALREADY_EXISTS
}

## Proxy files and folders that can represent new, overriden or deleted entries.
## The keys of the proxy are an absolute entry path and the value is a `FS.Entry`,
## For example, `{ "/Users/anthony/Downloads/test_folder": FS.Entry.new() }`.
var proxy: Dictionary = {}

func get_directory_entries(path: String) -> Array[FS.Entry]:
	var entries := FS.get_directory_entries(path)
	
	var modified_entry_paths: Array[String] = []
	var index: int = entries.size() - 1
	
	# Iterate over entries backwards so that they can be removed while looping.
	while index >= 0:
		var entry = entries[index]
		var proxy_entry = proxy.get(entry.path) as FS.Entry
		
		if proxy_entry:
			# Add to list of modified to exclude from being added as new entries.
			modified_entry_paths.append(entry.path)
			
			# Override entry with proxy, either delete it or replace it.
			if proxy_entry.is_deleted:
				entries.remove_at(index)
			else:
				entries[index] = proxy_entry
			
		index -= 1
		
	for proxy_path in proxy.keys():
		var base_proxy_path = (proxy_path as String).get_base_dir()
		
		# Only include proxy entries in that are in the current directory.
		if base_proxy_path != path:
			continue 
			
		# Exclude proxy entries that have already been modified.
		if modified_entry_paths.has(proxy_path):
			continue
			
		entries.append(proxy[proxy_path])
	
	return entries

func move(from: String, to: String) -> MoveError:
	var file_name = from.get_file()
	var new_path = to + "/" + file_name
	
	if exists(new_path):
		return MoveError.FILE_ALREADY_EXISTS
	
	var new_entry = FS.Entry.new()
	new_entry.file_name = file_name
	new_entry.file_name_without_extension = FS.get_file_name_without_extension(file_name)
	new_entry.path = new_path
	new_entry.is_directory = FS.is_directory(from)
	new_entry.extension = file_name.get_extension()
	
	var old_entry = FS.Entry.new()
	old_entry.file_name = file_name
	old_entry.file_name_without_extension = FS.get_file_name_without_extension(file_name)
	old_entry.path = from
	old_entry.is_directory = FS.is_directory(from)
	old_entry.extension = file_name.get_extension()
	old_entry.is_deleted = true
	
	proxy[new_path] = new_entry
	proxy[from] = old_entry
	
	var task = BackgroundTask.create(func():
		FS.move(from, to)
		proxy.erase(new_path)
		proxy.erase(from)
	)
	task.set_high_priority(true)
	task.start()
	
	return MoveError.NONE
	
func copy(from: String, to: String) -> void:
	pass
	
func trash(path: String) -> void:
	pass

func rename(path: String, new_name: String) -> void:
	pass

func exists(path: String) -> bool:
	if proxy.has(path):
		return true
	
	return FS.exists(path)
