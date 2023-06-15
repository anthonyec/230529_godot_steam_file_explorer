class_name MainState
extends State

var main: Shell

func awake() -> void:
	main = owner as Shell
	assert(main != null)
