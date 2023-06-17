class_name Sidebar
extends Window

@onready var panel: Panel = $"../Panel"

@export var is_open: bool = false

func _ready() -> void:
	size.y = get_parent().size.y
	visible = is_open
	
	if is_open:
		position = Vector2(0, 0)
	else:
		position = Vector2(-size.x, 0)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu", true):
		close()

func open() -> void:
	var open_tween = get_tree().create_tween()
	var panel_tween = get_tree().create_tween()
	
	SFX.play_everywhere("open_menu")
	
	visible = true
	
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
