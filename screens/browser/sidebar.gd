class_name Sidebar
extends Window

@onready var panel: Panel = %Panel
@onready var menu: ItemList = %Menu

@export var is_open: bool = false

func _ready() -> void:
	size.y = get_parent().size.y
	visible = is_open
	
	if is_open:
		position = Vector2(0, 0)
	else:
		position = Vector2(-size.x, 0)
		
	menu.connect("item_clicked", _on_item_clicked)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu", true):
		close()
		
	if event.is_action_released("ui_accept", true):
		var selected = menu.get_selected_items()
		_on_item_clicked(selected[0], Vector2(0, 0), 0)
		
	if event.is_action_released("options", true):
		ContextMenu.show("Shortcut options", [
			{
				"label": "Remove"
			},
			{
				"label": "---"
			},
			{
				"label": "Move up"
			},
			{
				"label": "Move down"
			}
		], self)

func _on_item_clicked(index: int, _at_positon: Vector2, _mouse_button: int) -> void:
	match index:
		0:
			get_parent().goto(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP))
		1:
			get_parent().goto(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS))
		2:
			get_parent().goto(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/test_folder")

	close()

func open() -> void:
	var open_tween = get_tree().create_tween()
	var panel_tween = get_tree().create_tween()
	
	SFX.play_everywhere("open_menu")
	
	visible = true
	
	menu.select(0)
	menu.grab_focus()
	
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
	
	# Important to release focus otherwise when re-opening the menu, arrow keys
	# do not change item selection until you press them 15+ times (don't know why).
	menu.release_focus()
	
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
