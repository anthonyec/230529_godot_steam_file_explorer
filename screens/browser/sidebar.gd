class_name Sidebar
extends Window

@onready var panel: Panel = %Panel
@onready var menu: ListMenu = %ListMenu as ListMenu
@onready var add_shortcut_button: Button = %AddShortcutButton

@export var is_open: bool = false

var browser: Browser

func _ready() -> void:
	size.y = get_parent().size.y
	visible = is_open
	browser = get_parent()
	
	if is_open:
		position = Vector2(0, 0)
	else:
		position = Vector2(-size.x, 0)
	
	load_shortcuts()
	
	menu.connect("updated", _on_menu_list_updated)
	menu.connect("emptied", _on_menu_list_emptied)
	menu.connect("item_clicked", _on_menu_list_item_clicked)
	add_shortcut_button.connect("pressed", _on_add_shortcut_button_clicked)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu", true) or event.is_action_pressed("ui_cancel", true):
		close()
		
	if event.is_action_released("options", true):
		ContextMenu.show("Shortcut options", [
			{
				"label": "Remove",
				"callback": _on_context_menu_remove
			},
			{
				"label": "---"
			},
			{
				"label": "Move up",
				"callback": _on_context_menu_move_up
			},
			{
				"label": "Move down",
				"callback": _on_context_menu_move_down
			}
		], self)

func _on_context_menu_remove() -> void:
	var index = menu.get_focused_index()
	menu.remove_item(index)
	
func _on_menu_list_updated() -> void:
	save_shortcuts()
	
func _on_menu_list_emptied() -> void:
	add_shortcut_button.grab_focus()
	
func _on_menu_list_item_clicked(index: int) -> void:
	var item = menu.items[index]
	var path = item.get("label", null)
	
	get_parent().goto(path)
	close()
	
func _on_context_menu_move_up() -> void:
	var index = menu.get_focused_index()
	menu.move_item(index, index - 1)
	
func _on_context_menu_move_down() -> void:
	var index = menu.get_focused_index()
	menu.move_item(index, index + 1)
	
func _on_add_shortcut_button_clicked() -> void:
	menu.add_item(get_parent().current_path)
	menu.focus_last()
	
func load_shortcuts() -> void:
	var file = FileAccess.open("user://shortcuts.json", FileAccess.READ)
	
	if not file:
		menu.set_items([])
		return
	
	var text = file.get_as_text()
	var json = JSON.parse_string(text)
	
	if json == null or typeof(json) != TYPE_ARRAY:
		# TODO: Delete file here, it's probably cursed.
		push_warning("Failed to load shortcuts")
		file.close()
		return
	
	var loaded_shortcuts: Array[Dictionary] = []
	
	# Annoyigly this has to be done otherwise I can't use types for `menu.items`.
	# There is always a type mismatch.
	# TODO: Maybe there is a better way to load JSON data and have it typed?
	for json_item in json:
		loaded_shortcuts.append(json_item)
		
	menu.set_items(loaded_shortcuts)
	file.close()
	
func save_shortcuts() -> void:
	var file = FileAccess.open("user://shortcuts.json", FileAccess.WRITE)
	var json = JSON.stringify(menu.items)
	
	file.store_string(json)
	file.close()

func open() -> void:
	var open_tween = get_tree().create_tween()
	var panel_tween = get_tree().create_tween()
	
	SFX.play_everywhere("open_menu")
	
	visible = true
	
	if menu.items.is_empty():
		add_shortcut_button.grab_focus()
	else:
		# TODO: Clean this up by using a helper function that
		# finds the closest match.
		var has_focused: bool = false
		
		for index in menu.items.size():
			var item = menu.items[index]
			var label = item.get("label", "") as String
			
			if browser.current_path.begins_with(label):
				menu.focus(index)
				has_focused = true
		
		if not has_focused:
			menu.focus(0)
	
	open_tween.set_ease(Tween.EASE_IN_OUT)
	open_tween.set_trans(Tween.TRANS_CUBIC)
	open_tween.tween_property(self, "position:x", 0, 0.25)
	
	panel_tween.set_ease(Tween.EASE_IN_OUT)
	panel_tween.set_trans(Tween.TRANS_CUBIC)
	panel_tween.set_parallel(true)
	panel_tween.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.25)
	panel_tween.tween_property(panel, "modulate", Color(0.8, 0.8, 0.8, 1), 0.25)
	
func close() -> void:
	var open_tween = get_tree().create_tween()
	var panel_tween = get_tree().create_tween()
	
	SFX.play_everywhere("close_menu")
	
	open_tween.set_ease(Tween.EASE_IN_OUT)
	open_tween.set_trans(Tween.TRANS_CUBIC)
	open_tween.tween_property(self, "position:x", -size.x, 0.25)
	
	panel_tween.set_ease(Tween.EASE_IN_OUT)
	panel_tween.set_trans(Tween.TRANS_CUBIC)
	panel_tween.set_parallel(true)
	panel_tween.tween_property(panel, "scale", Vector2(1, 1), 0.25)
	panel_tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.25)
	
	await open_tween.finished
	
	visible = false
