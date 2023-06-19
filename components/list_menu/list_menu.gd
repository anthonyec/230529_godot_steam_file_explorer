# TODO: Using this custom made list instead of `ItemList` because it has problems
# with regaining focus when showing a `ContextMenu`. No matter how many times I
# invoke `grab_focus` and different ways, it won't work. Not sure if bug?
class_name ListMenu
extends VBoxContainer

signal item_clicked(index: int)
signal updated
signal emptied

@export var items: Array[Dictionary]: set = set_items

var item_resource: PackedScene = preload("res://components/list_menu/item.tscn")

var focused_index: int = 0

func set_items(new_items: Array[Dictionary]) -> void:
	for child in get_children():
		remove_child(child)

	for index in new_items.size():
		var label = new_items[index].get("label", "")
		add_item(label, -1, true)
		
	items = new_items
	updated.emit()
	
func get_item(index: int) -> Button:
	if get_child_count() == 0:
		return

	return get_child(index) as Button
	
func add_item(label: String, index: int = -1, silent: bool = false) -> Button:
	var item: Button = item_resource.instantiate() as Button
	var inserted_index: int = get_child_count()
	
	item.text = label
	item.connect("focus_entered", _on_item_focused.bind(item))
	item.connect("pressed", _on_item_clicked.bind(item))
	
	add_child(item)
	items.append({ "label": label })
	
	if index != -1:
		move_child(item, index)
	
	if get_child_count() != 0:
		pass
		# TODO: Animate in.
#		item.custom_minimum_size.y = 0
	
	if not silent:
		updated.emit()
	
	return item
	
func remove_item(index: int) -> void:
	var item = get_item(index)
	var item_was_focused = focused_index == index
	
	# TODO: Animate out.
	remove_child(item)
	items.remove_at(index)
	
	if item_was_focused:
		focus(clamp(index - 1, 0, get_child_count() - 1))
		
	updated.emit()
	
	if get_child_count() == 0:
		emptied.emit()
	
func move_item(from_index: int, to_index: int) -> void:
	var item = get_item(from_index)
	# TODO: Animate move.
	move_child(item, to_index)
	items.insert(to_index, items[from_index].duplicate(true))
	items.remove_at(from_index)
	updated.emit()
	
func get_focused_index() -> int:
	return focused_index

func focus(index: int) -> void:
	var item = get_item(index)
	
	if item:
		item.grab_focus()
		
func focus_last() -> void:
	focus(get_child_count() - 1)

func _on_item_clicked(item: Button) -> void:
	item_clicked.emit(item.get_index())
	SFX.play_everywhere("enter")
	
func _on_item_focused(item: Button) -> void:
	focused_index = item.get_index()
	SFX.play_everywhere("highlight")
