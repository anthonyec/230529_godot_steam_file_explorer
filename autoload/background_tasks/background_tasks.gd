# Inspired by: https://gist.github.com/mashumafi/fced71eaf2ac3f90c158fd05d21379a3
extends Node

var tasks: Array[BackgroundTask] = []
var mutex: Mutex = Mutex.new()

func _process(_delta: float) -> void:
	mutex.lock()
	
	var completed_tasks := tasks.filter(func completed(task: BackgroundTask):
		return task.is_completed()
	)

	for completed_task in completed_tasks:
		var task: BackgroundTask = completed_task
		
		task.finished.emit()
		tasks.erase(task)
	
	mutex.unlock()
