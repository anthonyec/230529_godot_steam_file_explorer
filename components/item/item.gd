class_name Item
extends Control

@onready var text_label: Label = $Label
@onready var button: TextureButton = $TextureButton

@export var label: String = "Untitled item"
@export var highlighted: bool = false
@export var selected: bool = false

func _ready() -> void:
	render()
	
func render() -> void:
	text_label.text = label
	
	if highlighted:
		text_label.text = text_label.text + " <<<<"
		
	if selected:
		text_label.text = "[x] - " + text_label.text
	else:
		text_label.text = "[ ] - " + text_label.text

func highlight(should_highlight: bool) -> void:
	var tween = get_tree().create_tween()

	if should_highlight:
		tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.08)
	else:
		tween.tween_property(self, "scale", Vector2(1, 1), 0.08)
	
	highlighted = should_highlight
	render()

func select() -> void:
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "position:x", 5, 0.08)
	tween.tween_property(self, "position:x", 0, 0.08)
	
	selected = true
	
	render()

func deselect() -> void:
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "position:x", -5, 0.08)
	tween.tween_property(self, "position:x", 0, 0.08)
	
	selected = false
	render()
