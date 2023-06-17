class_name File
extends Node

signal changed(property_name: String, previous_value, next_value)

var index: int = -1
var id: String
var path: String

var file_name: String: set = set_file_name
var extension: String: set = set_extension
var is_directory: bool: set = set_is_directory
var is_disabled: bool: set = set_is_disabled
var is_selected: bool: set = set_is_selected

func _init(from_path: String = "", directory: bool = false) -> void:
	if from_path:
		id = File.get_id_from_path(from_path)
		file_name = from_path.get_file()
		extension = from_path.get_extension()
		path = from_path
		is_directory = directory
		
static func get_id_from_path(_path: String) -> String:
	return _path.md5_text()
	
static func new_from(file: File) -> File:
	return File.new(file.path, file.is_directory)

func set_file_name(value: String) -> void:
	var previous_value = file_name
	
	file_name = value
	changed.emit("file_name", previous_value, value)
	
func set_extension(value: String) -> void:
	var previous_value = extension
	
	extension = value
	changed.emit("extension", previous_value, value)
	
func set_is_directory(value: bool) -> void:
	var previous_value = is_directory
	
	is_directory = value
	changed.emit("is_directory", previous_value, value)
	
func set_is_disabled(value: bool) -> void:
	var previous_value = is_disabled
		
	is_disabled = value
	changed.emit("is_disabled", previous_value, value)
	
func set_is_selected(value: bool) -> void:
	var previous_value = is_selected
	
	is_selected = value
	changed.emit("is_selected", previous_value, value)
