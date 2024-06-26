extends Window

signal close

@export var options: Array[Dictionary] = []

@onready var title_label: Label = %Title
@onready var option_list: ItemList = %OptionList
@onready var vbox_container: VBoxContainer = %VBoxContainer

var target_path: String
var is_closing: bool = false
var items: Array = []

func _ready() -> void:
	connect("focus_exited", _on_focus_exited)

	title_label.text = title
	
	for option in options:
		if option.get("hidden", false):
			continue
		
		option_list.add_item(option.get("label", "<untitled>"))
		items.append(option)
		
	option_list.grab_focus()
	option_list.select(0)
	
	# TODO: Add resize listener.
#	maximize_screen(self)
	always_on_top = true
	
	animate_in()
	
func _input(event: InputEvent) -> void:
	if is_closing:
		return

	if event.is_action_released("ui_accept", true):
		var selected = option_list.get_selected_items()
		invoke_action(selected[0])
		
	if Input.is_action_just_released("ui_cancel", true) or Input.is_action_just_pressed("options", true):
		if is_closing:
			return
			
		is_closing = true
		await animate_out()
		close.emit()
		
func _exit_tree() -> void:
	queue_free() # @PREVENT_MEMORY_LEAK
	
func _on_focus_exited() -> void:
	if is_closing:
		return
		
	is_closing = true
	await animate_out()
	close.emit()

func _on_option_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	invoke_action(index)

func animate_in() -> Signal:
	var tween = get_tree().create_tween()
	
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(vbox_container, "scale", Vector2(1, 1), 0.2).from(Vector2(0.9, 0.9))
	tween.tween_property(vbox_container, "modulate", Color(1, 1, 1, 1), 0.2).from(Color(1, 1, 1, 0))
	
	return tween.finished
	
func animate_out() -> Signal:
	var tween = get_tree().create_tween()
	
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(vbox_container, "scale", Vector2(0.9, 0.9), 0.2)
	tween.tween_property(vbox_container, "modulate", Color(1, 1, 1, 0), 0.2)
	
	return tween.finished

func maximize_screen(window: Window) -> void:
	var viewpoint_size = get_parent().get_viewport().size
	
	window.size = Vector2i(viewpoint_size.x, viewpoint_size.y)
	window.position = Vector2i(0, 0)

func invoke_action(index: int) -> void:
	var option = items[index]
	
	if option.has("callback"):
		if is_closing:
			return
			
		is_closing = true
		
		await animate_out()
		
		close.emit()
		option.get("callback").call()
