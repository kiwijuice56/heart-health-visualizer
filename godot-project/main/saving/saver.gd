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
	
	print("Reloading recordings...")
	
	var root_path: String = Ref.file_selector.get_save_path()
	var root_dir: DirAccess = DirAccess.open(root_path)
	root_dir.list_dir_begin()
	
	var entry: String = root_dir.get_next()
	while entry != "":
		if root_dir.current_is_dir() and entry != "." and entry != "..":
			var sub_path: String = root_path + "/" + entry
			var sub_dir: DirAccess = DirAccess.open(sub_path)
			
			if sub_dir:
				sub_dir.list_dir_begin()
				var file: String = sub_dir.get_next()
				
				while file != "":
					var file_path: String = sub_path + "/" + file
					if file_path.ends_with(".csv") or not file_path.ends_with(".tres"):
						file = sub_dir.get_next()
						continue
					var resource: Resource = ResourceLoader.load(file_path)
					if resource is Recording:
						saved_recordings.append(resource as Recording)
					file = sub_dir.get_next()
		
		entry = root_dir.get_next()
	print("Done reloading recordings.")
	recordings_refreshed.emit(saved_recordings)

## Saved a recording to storage.
func save_recording(new_recording: Recording) -> void:
	var folder: String = ""
	if new_recording.user_id.length() == 0:
		folder = "myself"
	else:
		folder = new_recording.user_id.validate_filename()
	assert(folder.length() > 0)
	
	var root_path: String = Ref.file_selector.get_save_path() + folder + "/"
	DirAccess.make_dir_absolute(root_path)
	
	# Save the app resource
	var uuid: String = UUID.v4()
	var file_name: String = uuid + ".tres"
	ResourceSaver.save(new_recording, root_path + file_name)
	
	# Save the raw .csv for processing
	var csv_file_name: String = uuid + ".csv"
	var file_access: FileAccess = FileAccess.open(root_path + csv_file_name, FileAccess.WRITE)
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
		if path.ends_with(".csv") or path.contains(".tres") and ResourceLoader.load(path) is Recording:
			DirAccess.remove_absolute(path)
		file_name = dir.get_next()
	
	reload_recordings()
