class_name BrowserState
extends State

var browser: Browser

func awake() -> void:
	browser = owner as Browser
	assert(browser != null)
