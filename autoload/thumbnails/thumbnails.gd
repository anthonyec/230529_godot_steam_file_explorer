extends Node

class QueueItem:
	var path: String
	var callback: Callable

var queue: Array[QueueItem] = []
var is_processing_queue: bool = false
var should_terminate_threads: bool = false

var mutex: Mutex
var check_thread: Thread
var process_thread: Thread
var check_semaphore: Semaphore
var process_semaphore: Semaphore

var is_enabled: bool = false

func _ready() -> void:
	if not is_enabled:
		return
		
	var user_directory_access = DirAccess.open("user://")
	
	if not user_directory_access.dir_exists("thumbnails"):
		user_directory_access.make_dir("thumbnails")
	
	mutex = Mutex.new()
	
	check_thread = Thread.new()
	process_thread = Thread.new()
	
	process_semaphore = Semaphore.new()
	check_semaphore = Semaphore.new()
	
	check_thread.start(check_queue_thread)
	process_thread.start(process_queue_thread)
	
func _exit_tree():
	if not is_enabled:
		return
		
	should_terminate_threads = true
	
	check_semaphore.post()
	process_semaphore.post()
	
	check_thread.wait_to_finish()
	process_thread.wait_to_finish()
	
func check_queue_thread() -> void:
	while true:
		if should_terminate_threads: break
		
		mutex.lock()
		var is_queue_empty = queue.is_empty()
		mutex.unlock()
		
		if not is_queue_empty:
			debug_log("check_queue_thread->process_semaphore.post()")
			process_semaphore.post()
			
			debug_log("wait: check_queue_thread")
			check_semaphore.wait()

func process_queue_thread() -> void:
	while true:
		debug_log("wait: process_queue_thread")
		
		process_semaphore.wait()
		
		debug_log("start: process_queue_thread")
		
		if should_terminate_threads: break
		
		mutex.lock()
		
		var index = 0
		
		while index < queue.size():
			if should_terminate_threads: break
				
			var queue_item = queue[index]
			var path = queue_item.path
			var callback = queue_item.callback
			
			debug_log("process: " + path)
			var generated_thumbnail = generate_thumbnail(path)
			callback.call(generated_thumbnail)
		
			queue.remove_at(index)
			index += 1;
			
		mutex.unlock()
		check_semaphore.post()
		debug_log("end: process_queue_thread")
	

func get_thumbnail_name(path: String) -> String:
	return path.md5_text() + "." + path.get_extension()
	
func get_thumbnail_image_path(path: String) -> String:
	return "user://thumbnails/" + get_thumbnail_name(path)

func get_thumbnail(path: String, callback: Callable) -> Image:
	var queue_item = QueueItem.new()
	
	queue_item.path = path
	queue_item.callback = callback
	
	queue.append(queue_item)
	
	return Image.new()

func generate_thumbnail(path: String) -> Image:
	var existing_thumbnail = FileAccess.open(get_thumbnail_image_path(path), FileAccess.READ)

	if existing_thumbnail != null:
		var existing_thumbail_image = Image.new()
		existing_thumbail_image.load(get_thumbnail_image_path(path))
		return existing_thumbail_image
	
	var image = Image.new()
	var error = image.load(path)
	
	if error:
		push_warning("Failed to load image: ", path)
		return
	
	var original_width: int = image.get_width()
	var original_height: int = image.get_height()
	var ratio: float = float(original_height) / float(original_width)
	
	var new_width: int = 100
	var new_height: int = round(new_width * ratio)
	
	image.resize(new_width, new_height)
	
	var thumbnail_image = FileAccess.open(get_thumbnail_image_path(path), FileAccess.WRITE)
	
	assert(thumbnail_image.get_path().begins_with("user://"), "Thumbnail file should be located in `user://`, anywhere else is dangerous!")
	
	if thumbnail_image == null:
		push_warning("Failed to open thumbnails file for: ", path)
		return
	
	thumbnail_image.store_buffer(image.save_png_to_buffer())
	thumbnail_image.close()
	
	return image

func debug_log(message: String) -> void:
	print(message)
