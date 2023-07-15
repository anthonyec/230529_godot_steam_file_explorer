class_name WaitGroup
extends Node

signal finished

var count: int = 0

func add() -> void:
	count += 1
	
func done() -> void:
	count = clamp(count - 1, 0, INF)
	
	if count == 0:
		finished.emit()
