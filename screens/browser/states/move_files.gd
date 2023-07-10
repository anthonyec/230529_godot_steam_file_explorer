extends BrowserState

const OFFSET: Vector2 = Vector2(5, 5) 

var FilePlaceholder: PackedScene = preload("res://components/file_placeholder/file_placeholder.tscn")

var files: Array[File] = []
var grabbed_placeholders: Array[Panel] = []

func enter(params: Dictionary) -> void:
	assert(params.has("files"), "The `files` param is required")
	files = params.get("files")
	
	browser.grab_hand.appear()
	
	# Create file placeholder items.
	var placeholders: Array[Panel] = []
	
	for file in files:
		var item = browser.file_list.get_item_by_id(file.id)
		var rect = item.get_global_rect()
		var file_placeholder = FilePlaceholder.instantiate() as Panel
		
		file_placeholder.size = rect.size
		file_placeholder.position = rect.position
		
		browser.add_child(file_placeholder)
		placeholders.append(file_placeholder)
		
	# Reverse placeholders so that the ones nearer the bottom animate first.
	placeholders.reverse()
	
	# Animate placeholders to hand.
	for index in placeholders.size():
		var placeholder = placeholders[index]
		var tween = placeholder.create_tween()
		var end_position = browser.grab_hand.end_position + OFFSET * index
		
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(placeholder, "position", end_position, 0.3)
		tween.tween_property(placeholder, "size", Vector2(120, 50), 0.3)
		
		# Stagger animation between each placeholder.
		await tween.tween_interval(0.1).finished
		
		# When each placeholder tween finishes.
		tween.connect("finished", _on_placeholder_tween_finished.bind(placeholder))
		
		# Wait for last item to finish it's tween before exiting loop.
		if index == placeholders.size() - 1:
			await tween.finished

func _on_placeholder_tween_finished(placeholder: Panel) -> void:
	grabbed_placeholders.append(placeholder)
	browser.grab_hand.push(Vector2(1, 1))

func exit() -> void:
	browser.grab_hand.disappear()
	
func update(_delta: float) -> void:
	# Once a placeholder has been animated, is it then always positioned where the hand is.
	for index in grabbed_placeholders.size():
		var placeholder = grabbed_placeholders[index]
		placeholder.position = browser.grab_hand.position + OFFSET * index

func handle_input(event: InputEvent) -> void:
	pass
