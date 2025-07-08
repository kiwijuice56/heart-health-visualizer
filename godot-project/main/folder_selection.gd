class_name FileSelector extends FileDialog

@export var default_path: String = "user://recordings/"

signal save_path_updated(path: String)

var save_path: String
var location_selected: bool = false

func _init() -> void:
	if not DirAccess.dir_exists_absolute(default_path):
		DirAccess.make_dir_absolute(default_path)

func _ready() -> void:
	dir_selected.connect(_on_dir_selected)

func _on_dir_selected(dir: String) -> void:
	if not dir.ends_with("/"):
		save_path = dir + "/"
	else:
		save_path = dir
	location_selected = true
	save_path_updated.emit(save_path)

func get_save_path() -> String:
	if not location_selected:
		return default_path
	else:
		return save_path

func choose_folder() -> void:
	show()
