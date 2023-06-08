class_name MenuSelector
extends Node

signal item_highlighted(index: int)
signal item_selected(index: int)
signal item_deselected(index: int)
signal item_entered(index: int)
signal reached_start
signal reached_end

@export var number_of_items: int = 0
@export var focused: bool = true
@export var highlighted: int = 0
@export var selected: Array[int] = []

var has_reached_bounds: bool = false

func _ready() -> void:
	# Wait for top level parent to be ready, otherwise this may be invoked
	# before the node containing the children is ready. This would result in 
	# `null` children.
	await get_parent().ready
	highlight(highlighted)

func move(direction: int = 0) -> void:
	highlight(highlighted + direction)
	
func enter(index: int) -> void:
	item_entered.emit(index)

func toggled_selected(index: int) -> void:
	var found_index = selected.find(index)
	
	if found_index == -1:
		selected.append(index)
		item_selected.emit(index)
		return
	
	item_deselected.emit(index)
	selected.remove_at(found_index)
	
func highlight(index: int) -> void:
	var max_index: int = clamp(number_of_items - 1, 0, INF)
	
	highlighted = clamp(index, 0, max_index)
	
	# If there are no items, force selection to always be zero otherwise
	# we'll get negative indexes.
	if number_of_items == 0:
		highlighted = 0
		
	if index < 0:
		reached_start.emit()
		return
	
	if index > max_index:
		reached_end.emit()
		return
		
	item_highlighted.emit(highlighted)
	
func set_item_count(count: int) -> void:
	number_of_items = count
	highlight(highlighted)

func _process(_delta: float) -> void:
	if not focused:
		return
		
	if Input.is_action_just_pressed("mark"):
		toggled_selected(highlighted)
	
	if Input.is_action_just_pressed("ui_up"):
		move(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		move(1)
		
#	if Input.is_action_just_pressed("enter"):
#		enter(highlighted)
