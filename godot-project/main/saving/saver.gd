class_name Saver extends Node

var saved_recordings: Array[Recording]

signal recording_saved(recording: Recording)
signal recordings_refreshed(recordings: Array[Recording])

func _ready() -> void:
	Ref.file_selector.save_path_updated.connect(_on_save_path_updated)
	
	await get_tree().get_root().ready
	
	reload_recordings()

func _on_save_path_updated(_dir: String) -> void:
	reload_recordings()

## Refreshes saved recordings according to what exists in storage.
func reload_recordings() -> void:
	saved_recordings.clear()
	
	var dir: DirAccess = DirAccess.open(Ref.file_selector.get_save_path())
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		var path: String = dir.get_current_dir() + "/" + file_name
		var resource: Resource = ResourceLoader.load(path)
		if resource is Recording:
			var recording: Recording = resource as Recording
			saved_recordings.append(recording)
		file_name = dir.get_next()
	
	recordings_refreshed.emit(saved_recordings)

## Saved a recording to storage.
func save_recording(new_recording: Recording) -> void:
	# Save the app resource
	var uuid: String = UUID.v4()
	var file_name: String = uuid + ".tres"
	ResourceSaver.save(new_recording, Ref.file_selector.get_save_path() + file_name)
	
	# Save the raw .csv for processing
	var csv_file_name: String = uuid + ".csv"
	var file_access: FileAccess = FileAccess.open(Ref.file_selector.get_save_path() + csv_file_name, FileAccess.WRITE)
	# time | red channel
	for i in range(len(new_recording.raw_ppg_signal_timestamps)):
		file_access.store_csv_line([new_recording.raw_ppg_signal_timestamps[i], new_recording.raw_ppg_signal[i]])
	file_access.close()
	
	saved_recordings.append(new_recording)
	recording_saved.emit(new_recording)

func clear_all_data() -> void:
	saved_recordings.clear()
	
	var dir: DirAccess = DirAccess.open(Ref.file_selector.get_save_path())
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		var path: String = dir.get_current_dir() + "/" + file_name
		if path.ends_with(".csv") or ResourceLoader.load(path) is Recording:
			DirAccess.remove_absolute(path)
		file_name = dir.get_next()
	
	reload_recordings()
