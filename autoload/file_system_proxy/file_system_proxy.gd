extends Node

var entry_overrides: Dictionary = {}
var entry_additions: Dictionary = {}
var entry_deletions: Dictionary = {}

var proxy: Dictionary = {
	"/Users/anthony/Downloads/test_folder/1": FS.Entry.new(),
	"/Users/anthony/Downloads/test_folder/NEW_FILE": FS.Entry.new()
}

func get_proxy_entry(path: String) -> FS.Entry:
	return FS.Entry.new()

func get_directory_entries(path: String) -> Array[FS.Entry]:
	var entries := FS.get_directory_entries(path)
	
	var index: int = entries.size() - 1
	
	while index > 0:
		var entry = entries[index]
		var overrides = entry_overrides.get(path, []) as Array[FS.Entry]
		var deletions = entry_deletions.get(path, []) as Array[FS.Entry]
		
		var found_override = has_entry_by_file_name(overrides, entry.file_name)
		var found_deletion = has_entry_by_file_name(deletions, entry.file_name)
		
		if found_override:
			entries[index] = found_override
			
		if found_deletion:
			entries.remove_at(index)
			
		index -= 1
	
	for entry in entry_additions.get(path, []):
		entries.append(entry)
	
	return entries

func move(from: String, to: String) -> int:
	var file_name = from.get_file()
	var new_path = to + "/" + file_name
	var from_base_directory = from.get_base_dir()
	
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
	
	if not entry_additions.has(to):
		entry_additions[to] = []
		
	# TODO: Add fail for tryingto move folder inside itself.
	if has_entry_by_file_name(entry_additions[to], file_name):
		return 1
		
	if FS.exists(new_path):
		return 1
		
	entry_additions[to].append(new_entry)
	
	if not entry_deletions.has(from_base_directory):
		entry_deletions[from_base_directory] = []
		
	entry_deletions[from_base_directory].append(old_entry)
	
#	FS.move(from, to)
	return 0

# TODO: Fix
func has_entry_by_file_name(entries: Array, file_name: String) -> bool:
	var found_entries = entries.filter(func(entry: FS.Entry):
		return entry.file_name == file_name
	)
	
	return not found_entries.is_empty()
	
func copy(from: String, to: String) -> void:
	pass
	
func trash(path: String) -> void:
	pass

func rename(path: String, new_name: String) -> void:
	pass

func exists(path: String) -> void:
	pass
