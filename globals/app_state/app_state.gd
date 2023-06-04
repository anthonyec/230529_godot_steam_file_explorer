extends Node

signal current_path_updated
signal moving_file_updated
signal browser_mode_updated

enum BrowserMode {
	DEFAULT,
	MOVE
}

var current_path: String: set = set_current_path
var moving_file: File: set = set_moving_file
var browser_mode: BrowserMode: set = set_browser_mode
	
func set_current_path(value: String) -> void:
	current_path = value
	current_path_updated.emit()
	
func set_moving_file(value: File) -> void:
	moving_file = value
	moving_file_updated.emit()

func set_browser_mode(value: BrowserMode) -> void:
	browser_mode = value
	browser_mode_updated.emit()
