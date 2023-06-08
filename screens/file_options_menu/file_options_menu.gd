extends Screen

@onready var option_list: ItemList = %OptionList as ItemList

var target_path: String

func open(path: String) -> void:
	target_path = path
	option_list.grab_focus()
	option_list.select(0)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		close.emit()

func _on_option_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	print("_on_option_list_item_clicked", index)
	
	if index == 0:
		print("CLOSE_AND_OPEN", target_path)
