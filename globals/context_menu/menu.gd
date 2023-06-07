extends Window

signal close

@export var options: Array[Dictionary] = []

@onready var title_label: Label = %Title
@onready var option_list: ItemList = %OptionList
@onready var vbox_container: VBoxContainer = %VBoxContainer

var target_path: String
var is_closing: bool = false

func _ready() -> void:
	title_label.text = title
	
	for option in options:
		option_list.add_item(option.get("label", "<untitled>"))
		
	option_list.grab_focus()
	option_list.select(0)
	
	# TODO: Add resize listener.
	maximize_screen(self)
	always_on_top = true
	
	animate_in()
	
func _process(_delta: float) -> void:
	if is_closing:
		return

func _input(event: InputEvent) -> void:
	if event.is_action_released("enter", true) or event.is_action_released("ui_accept", true):
		var selected = option_list.get_selected_items()
		invoke_action(selected[0])
		
	if Input.is_action_just_released("back", true) or Input.is_action_just_pressed("options", true):
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
	var option = options[index]
	
	if option.has("callback"):
		var callback = option.get("callback")
		
		callback.call()
		is_closing = true
		await animate_out()
		close.emit()
