extends Node

signal menu_opened
signal menu_closed

var menu_scene: PackedScene = preload("res://autoload/context_menu/menu.tscn")

var current_menu: Window = null
var previously_focused_window: Viewport = null
var previously_focused_control: Control = null

func show(title: String, options: Array[Dictionary], window: Window = null) -> void:
	if window:
		previously_focused_window = window
		previously_focused_control = window.get_viewport().gui_get_focus_owner()
	
	menu_opened.emit()
	
	var menu = menu_scene.instantiate()
	
	menu.connect("close", _on_menu_close)
	menu.title = title
	menu.options = options
	
	add_child(menu)
	current_menu = menu
	
	SFX.play_everywhere("deselect")

func _on_menu_close() -> void:
	if previously_focused_window:
		previously_focused_window.grab_focus()
		
	if previously_focused_control:
		previously_focused_control.grab_focus()
	
	remove_child(current_menu)
	current_menu = null
	
	await get_tree().create_timer(0.1).timeout
	
	menu_closed.emit()
