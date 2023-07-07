class_name BackgroundTask

signal finished

var id: int
var callable: Callable
var description: String
var high_piority: bool = false

func _init(callable) -> void:
	self.callable = callable
	
static func create(callable: Callable) -> BackgroundTask:
	return BackgroundTask.new(callable)
	
func is_completed() -> bool:
	return WorkerThreadPool.is_task_completed(self.id)

func wait() -> void:
	WorkerThreadPool.wait_for_task_completion(self.id)
	
func set_high_priority(high_piority: bool) -> BackgroundTask:
	self.high_piority = high_piority
	return self
	
func set_description(description: String) -> BackgroundTask:
	self.description = description
	return self
	
func start() -> BackgroundTask:
	self.id = WorkerThreadPool.add_task(
		self.callable, 
		self.high_piority, 
		self.description
	)
	
	BackgroundTasks.mutex.lock()
	BackgroundTasks.tasks.append(self)
	BackgroundTasks.mutex.unlock()
	
	return self
