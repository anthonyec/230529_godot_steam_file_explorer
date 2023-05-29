class_name FileList
extends Control

signal file_selected(file: File)
signal list_back()

@onready var menu: MenuSelector = $MenuSelector as MenuSelector
@onready var list: VBoxContainer = %VBoxContainer
@onready var scroll_view: ScrollContainer = $ScrollContainer

var files: Array[File] = []

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		back()
	
func get_items() -> Array[Node]:
	menu.number_of_items = list.get_child_count()
	
	return list.get_children()
	
func set_items(new_items: Array[File]) -> void:
	files = new_items
	
	for child in list.get_children():
		list.remove_child(child)
		
	for file in files:
		var list_item_resource = preload("res://item.tscn")
		var list_item = list_item_resource.instantiate() as Item
		
		list_item.label = file.file_name
		
		list.add_child(list_item)
		
	menu.set_item_count(list.get_child_count())
	_on_menu_item_highlighted(menu.highlighted)

func _on_menu_item_highlighted(index: int) -> void:
	var items = get_items() as Array[Item]
	
	if items.size() == 0:
		return
	
	for item in items:
		item.highlight(false)
		
	var item_to_highlight = items[index]
	
	var item_rect = item_to_highlight.get_rect()
	var item_screen_position = item_to_highlight.get_screen_position()
	var scroll_rect = scroll_view.get_rect()
	var scroll_screen_position = scroll_view.get_screen_position()
	
	var item_bottom = item_screen_position.y + item_rect.size.y
	var scroll_view_bottom = scroll_screen_position.y + scroll_rect.size.y
	
	if item_screen_position.y < scroll_screen_position.y or item_bottom > scroll_view_bottom:
		# TODO: Take into account how much scrolling is left so that it scrolls 
		# smoothly to the end, instead of trying to scroll a fixed size.
		var new_scroll_position = item_to_highlight.position.y - (scroll_rect.size.y / 2)
		var scroll_tween = get_tree().create_tween()
		
		scroll_tween.tween_property(scroll_view, "scroll_vertical", new_scroll_position, 0.2) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_CIRC)
			
	item_to_highlight.highlight(true)
	SFX.play_everywhere("highlight")

func _on_menu_reached_start() -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(scroll_view, "position:y", 10.0, 0.05)
	tween.tween_property(scroll_view, "position:y", 0, 0.05)
	
	SFX.play_everywhere("invalid")

func _on_menu_reached_end() -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(scroll_view, "position:y", -10.0, 0.05)
	tween.tween_property(scroll_view, "position:y", 0, 0.05)
	
	SFX.play_everywhere("invalid")

func _on_menu_selector_item_selected(index: int) -> void:
	var items = get_items() as Array[Item]
	
	if items.size() == 0:
		return
	
	items[index].select()
	
	SFX.play_everywhere("select")

func _on_menu_selector_item_deselected(index) -> void:
	var items = get_items() as Array[Item]
	
	if items.size() == 0:
		return
	
	items[index].deselect()
	
	SFX.play_everywhere("deselect")

func _on_menu_selector_item_entered(index) -> void:
	SFX.play_everywhere("enter")
	
	var tween = get_tree().create_tween().set_parallel(true)

	tween.tween_property(scroll_view, "scale", Vector2(2, 2), 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(scroll_view, "modulate", Color(1, 1, 1, 0), 0.3).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	file_selected.emit(files[index])
	
	var tween_2 = get_tree().create_tween().set_parallel(true)
	
	tween_2.tween_property(scroll_view, "scale", Vector2(1, 1), 0.3).from(Vector2(0, 0)).set_trans(Tween.TRANS_SINE)
	tween_2.tween_property(scroll_view, "modulate", Color(1, 1, 1, 1), 0.3).set_trans(Tween.TRANS_SINE)
	
func back() -> void:
	SFX.play_everywhere("back")
	
	var tween = get_tree().create_tween().set_parallel(true)

	tween.tween_property(scroll_view, "scale", Vector2(0, 0), 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(scroll_view, "modulate", Color(1, 1, 1, 0), 0.3).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	list_back.emit()
	
	var tween_2 = get_tree().create_tween().set_parallel(true)
	
	tween_2.tween_property(scroll_view, "scale", Vector2(1, 1), 0.3).from(Vector2(2, 2)).set_trans(Tween.TRANS_SINE)
	tween_2.tween_property(scroll_view, "modulate", Color(1, 1, 1, 1), 0.3).set_trans(Tween.TRANS_SINE)
	
	
