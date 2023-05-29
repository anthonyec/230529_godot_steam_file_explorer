extends Control

@onready var textarea: TextEdit = $TextEdit

func _ready() -> void:
	var desktop_directory = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var downloads_directory = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	
	_print(desktop_directory)
	_print(downloads_directory)
	
	var file = FileAccess.open(downloads_directory + "/_test.txt", FileAccess.WRITE)
	
	_print(file)
	
	file.store_string("hello")
	
	_print("file write!")
	
	file.close()
	
	var file_2 = FileAccess.open(downloads_directory + "/_test.txt", FileAccess.READ)
	var file_text = file_2.get_as_text()
	
	_print("contents: " + file_text)
	
	file_2.close()
	
	var directory = DirAccess.open(downloads_directory)
	
	directory.remove(downloads_directory + "/_test.txt")
	
	_print("deleted!")
	
	var output = []
	var exit_code = OS.execute("ls", ["-l", "/tmp"], output)
	
	_print("exit_code: " + str(exit_code))
	_print("output: " + str(output))
	
	var zip_result_1 = write_zip_file(downloads_directory)
	var zip_result_2 = write_zip_file(desktop_directory)
	
	_print(zip_result_1)
	_print(zip_result_2)
	
	var zip_read_1 = read_zip_file(downloads_directory)
	var zip_read_2 = read_zip_file(desktop_directory)
	
	_print(zip_read_1)
	_print(zip_read_2)
	
	Steam.steamInit()
	
	var steam_name = Steam.getPersonaName()
	
	Steam.showGamepadTextInput(
		Steam.GAMEPAD_TEXT_INPUT_MODE_NORMAL, 
		Steam.GAMEPAD_TEXT_INPUT_LINE_MODE_SINGLE_LINE,
		"File name",
		256,
		"Hey"
	)
	
	_print("Steam name:" + steam_name)
	
	
func write_zip_file(path: String):
	var writer := ZIPPacker.new()
	var err := writer.open(path + "/archive.zip")
	
	if err != OK:
		return err
		
	writer.start_file("hello.txt")
	writer.write_file("Hello World".to_utf8_buffer())
	writer.close_file()
	writer.close()
	
	return OK
	
func read_zip_file(path: String):
	var reader := ZIPReader.new()
	var err := reader.open(path + "/archive.zip")
	
	if err != OK:
		_print("read zip error!")
		return PackedByteArray()
		
	_print("files:")
	_print(reader.get_files())
		
	var res := reader.read_file("hello.txt")
	
	reader.close()

	return res.get_string_from_ascii()

func _print(text: Variant) -> void:
	print(text)
	textarea.text += str(text) + "\n"
