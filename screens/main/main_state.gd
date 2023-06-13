class_name MainState
extends State

var main: Main

func awake() -> void:
	main = owner as Main
	assert(main != null)
