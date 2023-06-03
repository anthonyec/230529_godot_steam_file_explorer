extends Window

signal close

@export var options: Array[Dictionary] = []

@onready var option_list: ItemList = %OptionList as ItemList

var target_path: String
var is_closing: bool = false

func _ready() -> void:
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
		
	if Input.is_action_just_released("back") or Input.is_action_just_pressed("options"):
		is_closing = true
		await animate_out()
		close.emit()

func _on_option_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	var option = options[index]
	
	if option.has("callback"):
		var callback = option.get("callback")
		
		callback.call()
		is_closing = true
		await animate_out()
		close.emit()

func animate_in() -> Signal:
	var tween = get_tree().create_tween()
	
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(option_list, "scale", Vector2(1, 1), 1).from(Vector2(0.5, 0.5))
	tween.tween_property(option_list, "modulate", Color(1, 1, 1, 1), 1).from(Color(1, 1, 1, 0))
	
	return tween.finished
	
func animate_out() -> Signal:
	var tween = get_tree().create_tween()
	
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(option_list, "scale", Vector2(0.5, 0.5), 0.2)
	tween.tween_property(option_list, "modulate", Color(1, 1, 1, 0), 0.2)
	
	return tween.finished

func maximize_screen(window: Window) -> void:
	var viewpoint_size = get_parent().get_viewport().size
	
	window.size = Vector2i(viewpoint_size.x, viewpoint_size.y)
	window.position = Vector2i(0, 0)
