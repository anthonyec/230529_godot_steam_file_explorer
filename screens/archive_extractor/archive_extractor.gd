extends Screen

@onready var texture_rect: TextureRect = %TextureRect as TextureRect
@onready var progress_bar: ProgressBar = %ProgressBar as ProgressBar

var target_path: String

class Extraction:
	signal progress(percent: float)
	signal started
	signal finished
	signal error

func _ready() -> void:
	super()
	$Panel/CloseButton.grab_focus()

func open(path: String) -> void:
	target_path = path
	
func get_controls() -> Dictionary:
	return {
		"ui_cancel": {
			"label": "Exit",
			"callback": func(): close.emit()
		}
	}
	
func extract(path: String) -> void:
	var zip_reader = ZIPReader.new()
	var error: Error = zip_reader.open(path)
	
	if error != OK:
		push_error("Failed to open ZIP: ", path)
		return
	
	var temporary_extraction_directory = FS.create_temporary_directory()
	
	if temporary_extraction_directory == null:
		push_error("Failed to create temporary directory")
		return
	
	var file_paths: PackedStringArray = zip_reader.get_files()
	
	for index in file_paths.size():
		var file_path = file_paths[index]
		var file: PackedByteArray = zip_reader.read_file(file_path)
		
		# Create directories that the file will exist in.
		temporary_extraction_directory.make_dir_recursive(file_path.get_base_dir())
		
		if file:
			var new_file = FileAccess.open(
				temporary_extraction_directory.get_current_dir() + "/" + file_path,
				FileAccess.WRITE
			)
			
			new_file.store_buffer(file)
			new_file.close()
	
	zip_reader.close()
	
	var temp_path = temporary_extraction_directory.get_current_dir()
	
	FS.move(
		ProjectSettings.globalize_path(temp_path),
		path.get_base_dir()
	)
		
func create_extraction_directory(path: String) -> String:
	var parent_path = path.get_base_dir()
	var folder_name = path.get_file()
	var extension = folder_name.get_extension()
	
	# TODO: Make this a helper, like `Path.get_name_without_extension`.
	folder_name = folder_name.trim_suffix("." + extension)
	
	var dir_access = DirAccess.open(parent_path)
	var extraction_path = parent_path + "/" + folder_name
	
	# TODO: Increment folder number, see Salad Room source on how it does this.
	if dir_access.dir_exists(extraction_path):
		push_error("Extraction folder already exists!")
		
		# TODO: Return error type.
		return ""
	
	dir_access.make_dir(parent_path + "/" + folder_name)
	
	return extraction_path

func _on_close_button_pressed() -> void:
	close.emit()

func _on_extract_button_pressed() -> void:
	extract(target_path)
