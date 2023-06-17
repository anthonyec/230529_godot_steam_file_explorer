class_name Spring
extends Node

@export var stiffness: float = 50
@export var mass: float = 1
@export var damping: float = 2
@export var length: float = 1

var x: float = 0
var velocity: float = 0

var k: float = 0
var d: float = 0

func _process(delta: float) -> void:
	k = -stiffness
	d = -damping
	
	var f_spring = k * (x - length)
	var f_damping = d * velocity
	var a = (f_spring + f_damping) / mass

	velocity += a * delta;
	x += velocity * delta;

func add_velocity(value: float) -> void:
	velocity += value
