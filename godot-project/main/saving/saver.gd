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
	var folder: String = get_folder_name(new_recording)
	assert(folder.length() > 0)
	
	var root_path: String = Ref.file_selector.get_save_path() + folder + "/"
	DirAccess.make_dir_absolute(root_path)
	
	# Save the app resource
	ResourceSaver.save(new_recording, root_path + new_recording.uuid + ".tres")
	
	# Save the raw .csv for processing
	var file_access: FileAccess = FileAccess.open(root_path + new_recording.uuid + ".csv", FileAccess.WRITE)
	# time | red channel
	for i in range(len(new_recording.raw_ppg_signal_timestamps)):
		file_access.store_csv_line([new_recording.raw_ppg_signal_timestamps[i], new_recording.raw_ppg_signal[i]])
	file_access.close()
	
	saved_recordings.append(new_recording)
	recording_saved.emit(new_recording)

# TODO: Fix to account for new structure
func clear_all_data() -> void:
	assert(false, "Not implemented.")
	
	saved_recordings.clear()
	
	# ...
	
	reload_recordings()

func delete_recording(recording: Recording) -> void:
	var folder: String = get_folder_name(recording)
	var root_path: String = Ref.file_selector.get_save_path() + folder + "/"
	DirAccess.remove_absolute(root_path + recording.uuid + ".csv")
	DirAccess.remove_absolute(root_path + recording.uuid + ".tres")
	reload_recordings()

func get_folder_name(recording: Recording) -> String:
	var folder: String = ""
	if recording.user_id.length() == 0:
		folder = "myself"
	else:
		folder = recording.user_id.validate_filename()
	return folder
