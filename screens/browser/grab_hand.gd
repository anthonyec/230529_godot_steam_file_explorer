class_name GrabHand
extends TextureRect

@onready var spring: Spring = $Spring as Spring

var end_position: Vector2

func _process(_delta: float) -> void:
	var viewport_size = Vector2(get_viewport().size)
	var start_position: Vector2 = viewport_size + Vector2(50, 50)
	
	end_position = viewport_size - Vector2(200, 200)
	position = start_position.lerp(end_position, spring.x)
	
func disappear() -> void:
	spring.length = 0
	
func appear() -> void:
	spring.length = 1

func push(_direction: Vector2) -> void:
	# TODO: Do something with `direction`.
	spring.add_velocity(-5)
