extends Node

var entry_overrides: Dictionary = {}
var entry_additions: Dictionary = {}

func get_directory_entries(path: String) -> Array[FS.Entry]:
	var entries := FS.get_directory_entries(path)
	
	for index in entries.size():
		var entry = entries[index]
		var overrides = entry_overrides.get(path, []) as Array[FS.Entry]
		
		var found_override = overrides.filter(func(override):
			return override.file_name == entry.file_name
		)
		
		if found_override:
			entries[index] = found_override
	
	for entry in entry_additions.get(path, []):
		entries.append(entry)
	
	return entries

func move(from: String, to: String) -> int:
	var file_name = from.get_file()
	var new_path = to + "/" + file_name
	
	var entry = FS.Entry.new()
	
	entry.file_name = file_name
	entry.file_name_without_extension = FS.get_file_name_without_extension(file_name)
	entry.path = new_path
	entry.is_directory = FS.is_directory(from)
	entry.extension = file_name.get_extension()
	
	if not entry_additions.has(to):
		entry_additions[to] = []
		
	if has_entry_by_file_name(entry_additions[to], file_name):
		return 1
		
	if FS.exists(new_path):
		return 1
		
	entry_additions[to].append(entry)
	
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
