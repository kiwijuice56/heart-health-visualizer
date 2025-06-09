class_name Saver extends Node

@export var recording_path: String = "user://recordings/"

var saved_recordings: Array[Recording]

signal recording_saved(recording: Recording)
signal recordings_refreshed(recordings: Array[Recording])

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(recording_path):
		DirAccess.make_dir_absolute(recording_path)
	
	await get_tree().get_root().ready
	
	reload_recordings()

## Refreshes saved recordings according to what exists in storage.
func reload_recordings() -> void:
	saved_recordings.clear()
	
	var dir: DirAccess = DirAccess.open(recording_path)
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		print(file_name)
		var path: String = dir.get_current_dir() + "/" + file_name
		var resource: Resource = ResourceLoader.load(path)
		if resource is Recording:
			var recording: Recording = resource as Recording
			saved_recordings.append(recording)
		file_name = dir.get_next()
	
	recordings_refreshed.emit(saved_recordings)

## Saved a recording to storage.
func save_recording(new_recording: Recording) -> void:
	var file_name: String = UUID.v4() + ".tres"
	ResourceSaver.save(new_recording, recording_path + file_name)
	saved_recordings.append(new_recording)
	recording_saved.emit(new_recording)
