extends BrowserState

var file: File = null
var strength: float = 0
var original_position: Vector2
var was_grabbing: bool = false

var noise: Array[FastNoiseLite]

func awake() -> void:
	super()
	noise.append(create_perlin_noise())
	noise.append(create_perlin_noise())

func enter(params: Dictionary) -> void:
	assert(params.has("file"), "File param required")
	file = params.file
	
	var item: FileItem = browser.file_list.get_item_by_id(file.id)
	original_position = item.position
	
	browser.grab_hand.appear()
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_released("grab", true) and was_grabbing:
		was_grabbing = false
		strength = 0
		grab_released()
		return
		
	if event.is_action_pressed("grab", true):
		was_grabbing = true
		strength = event.get_action_strength("grab", true)

func update(delta: float) -> void:
	if not file:
		return
		
	var item: FileItem = browser.file_list.get_item_by_id(file.id)
	
	if not item:
		state_machine.transition_to("Default")
		return
	
	var offset = Vector2(
		noise[0].get_noise_1d(Time.get_ticks_msec()), 
		noise[1].get_noise_1d(Time.get_ticks_msec())
	) * strength * 10
	
	item.position = original_position + offset

	if strength > 0.8 and state_machine.time_in_current_state > 100:
		state_machine.transition_to("MoveFile", {
			"file": file,
			"grabbing": true,
			"original_position": original_position
		})

func create_perlin_noise() -> FastNoiseLite:
	var perlin_noise = FastNoiseLite.new()
	
	perlin_noise.seed = randi()
	perlin_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	return perlin_noise
	
func grab_released() -> void:
	print("grab released")
	
	var item: FileItem = browser.file_list.get_item_by_id(file.id)
	item.position = original_position
	
	state_machine.transition_to("Default")
