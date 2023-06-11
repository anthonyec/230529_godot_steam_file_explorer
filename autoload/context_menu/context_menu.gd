extends Node

signal menu_opened
signal menu_closed

var menu_scene: PackedScene = preload("res://autoload/context_menu/menu.tscn")

var current_menu: Window = null

func show(title: String, options: Array[Dictionary]) -> void:
	menu_opened.emit()
	
	var menu = menu_scene.instantiate()
	
	menu.connect("close", _on_menu_close)
	menu.title = title
	menu.options = options
	
	add_child(menu)
	current_menu = menu
	
	SFX.play_everywhere("deselect")

func _on_menu_close() -> void:
	remove_child(current_menu)
	current_menu = null
	
	await get_tree().create_timer(0.1).timeout
	
	menu_closed.emit()
