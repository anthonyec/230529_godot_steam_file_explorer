class_name File
extends Node

signal updated

var index: int = -1
var id: String
var path: String

var file_name: String: set = set_file_name
var extension: String: set = set_extension
var is_directory: bool: set = set_is_directory
var is_disabled: bool: set = set_is_disabled

func set_file_name(value: String) -> void:
	file_name = value
	updated.emit()
	
func set_extension(value: String) -> void:
	extension = value
	updated.emit()
	
func set_is_directory(value: bool) -> void:
	is_directory = value
	updated.emit()
	
func set_is_disabled(value: bool) -> void:
	is_disabled = value
	updated.emit()
