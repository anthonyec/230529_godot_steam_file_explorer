extends Node

signal updated(path: String)

enum MoveError {
	NONE = 0,
	FILE_ALREADY_EXISTS
}

## Proxy files and folders can represent new, overriden or deleted entries. The 
## keys of the proxy are an absolute entry path and the value is a `FS.Entry`,
## Example: `{ "/Users/anthony/Downloads/test_folder": FS.Entry.new() }`.
var proxy: Dictionary = {}

func get_directory_entries(path: String) -> Array[FS.Entry]:
	var entries := FS.get_directory_entries(path)
	
	var modified_entry_paths: Array[String] = []
	var index: int = entries.size() - 1
	
	# Replace entries with proxy entries, either delete it or replace it.
	while index >= 0:
		var entry = entries[index]
		var proxy_entry = proxy.get(entry.path) as FS.Entry
		
		if proxy_entry:
			modified_entry_paths.append(entry.path)
			
			if proxy_entry.is_deleted:
				entries.remove_at(index)
			else:
				entries[index] = proxy_entry
			
		index -= 1
		
	# Add any proxy entries that are new.
	for proxy_path in proxy.keys():
		var base_proxy_path = (proxy_path as String).get_base_dir()
		
		if base_proxy_path != path:
			continue 
			
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
	new_entry.is_directory = is_directory(from)
	new_entry.is_transient = true
	new_entry.extension = file_name.get_extension()
	
	var old_entry = FS.Entry.new()
	old_entry.file_name = file_name
	old_entry.file_name_without_extension = FS.get_file_name_without_extension(file_name)
	old_entry.path = from
	old_entry.is_directory = is_directory(from)
	old_entry.extension = file_name.get_extension()
	old_entry.is_deleted = true
	
	proxy[new_path] = new_entry
	proxy[from] = old_entry
	
	var task = BackgroundTask.create(func():
		# TODO: Add way for tasks to error and abort.
		FS.move(from, to)
		proxy.erase(new_path)
		proxy.erase(from)
	)
	task.set_high_priority(true)
	task.start()
	
	return MoveError.NONE
	
func copy(from: String, to: String) -> int:
	var file_name = from.get_file()
	
	if exists(to):
		return MoveError.FILE_ALREADY_EXISTS
	
	var new_entry = FS.Entry.new()
	new_entry.file_name = file_name
	new_entry.file_name_without_extension = FS.get_file_name_without_extension(file_name)
	new_entry.path = to
	new_entry.extension = file_name.get_extension()
	new_entry.is_transient = true
	new_entry.is_directory = is_directory(from)
	
	proxy[to] = new_entry
	
	var task = BackgroundTask.create(func():
		FS.copy(from, to)
		proxy.erase(to)
	)
	task.set_high_priority(true)
	task.start()
	
	return 0
	
func trash(path: String) -> int:
	var file_name = path.get_file()
	
	var new_entry = FS.Entry.new()
	new_entry.file_name = file_name
	new_entry.file_name_without_extension = FS.get_file_name_without_extension(file_name)
	new_entry.path = path
	new_entry.is_deleted = true
	new_entry.extension = file_name.get_extension()
	
	proxy[path] = new_entry
	
	var task = BackgroundTask.create(func():
		FS.trash(path)
		proxy.erase(path)
	)
	task.set_high_priority(true)
	task.start()
	
	return 0

func exists(path: String) -> bool:
	if proxy.has(path):
		return true
	
	return FS.exists(path)
	
func is_directory(path: String) -> bool:
	var proxy_entry = proxy.get(path) as FS.Entry
	
	if proxy_entry:
		return proxy_entry.is_directory
	
	var dir_access = DirAccess.open(path)
	
	if dir_access:
		return true
	
	return false
	
func get_next_file_name(path: String) -> String:
	var base_directory = path.get_base_dir()
	var plain_name = FS.get_file_name_without_extension(path)
	var extension = FS.get_extension(path, true)
	
	var copy_suffix = FS.duplicate_regex.search(plain_name)
	var name_without_suffix = FS.duplicate_regex.sub(plain_name, "")
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
