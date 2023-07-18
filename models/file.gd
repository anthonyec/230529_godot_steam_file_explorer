class_name File
extends Node

signal changed(property_name: String, previous_value, next_value)

var index: int = -1
var id: String
var path: String

var file_name: String: set = set_file_name
var extension: String: set = set_extension
var size: int: set = set_size
var is_directory: bool: set = set_is_directory
var is_disabled: bool: set = set_is_disabled
var is_selected: bool: set = set_is_selected
var is_invisible: bool: set = set_is_invisible

func _init(from_path: String = "", directory: bool = false, size: int = 0) -> void:
	if from_path:
		id = File.get_id_from_path(from_path)
		file_name = from_path.get_file()
		extension = from_path.get_extension()
		path = from_path
		is_directory = directory
		size = size
		
static func get_id_from_path(_path: String) -> String:
	return _path.md5_text()
	
static func new_from(files: Array[File]) -> Array[File]:
	var new_files: Array[File] = []
	
	for file in files:
		new_files.append(File.new(file.path, file.is_directory))
	
	return new_files

static func new_from_entry(entry: FS.Entry) -> File:
	var new_file = File.new(entry.path, entry.is_directory, entry.size)
	new_file.is_disabled = entry.is_transient
	return new_file

func set_file_name(value: String) -> void:
	var previous_value = file_name
	
	if previous_value == value:
		return
	
	file_name = value
	changed.emit("file_name", previous_value, value)
	
func set_extension(value: String) -> void:
	var previous_value = extension
	
	if previous_value == value:
		return
	
	extension = value
	changed.emit("extension", previous_value, value)
	
func set_size(value: int) -> void:
	var previous_value = extension
	
	if previous_value == value:
		return
	
	size = value
	changed.emit("size", previous_value, value)
	
func set_is_directory(value: bool) -> void:
	var previous_value = is_directory
	
	if previous_value == value:
		return
	
	is_directory = value
	changed.emit("is_directory", previous_value, value)
	
func set_is_disabled(value: bool) -> void:
	var previous_value = is_disabled
	
	if previous_value == value:
		return
		
	is_disabled = value
	changed.emit("is_disabled", previous_value, value)
	
func set_is_selected(value: bool) -> void:
	var previous_value = is_selected
	
	if previous_value == value:
		return
	
	is_selected = value
	changed.emit("is_selected", previous_value, value)
	
func set_is_invisible(value: bool) -> void:
	var previous_value = is_invisible
	
	if previous_value == value:
		return
	
	is_invisible = value
	changed.emit("is_invisible", previous_value, value)
