class_name SavedRecordingContainer extends GridContainer

@export var saved_recording_panel_scene: PackedScene = preload("res://main/ui/menu/history/saved_recording_panel/saved_recording_panel.tscn")

func _ready() -> void:
	Ref.saver.recordings_refreshed.connect(_on_recordings_refreshed)
	Ref.saver.recording_saved.connect(_on_recording_saved)

func _on_recordings_refreshed(recordings: Array[Recording]) -> void:
	delete_all_panels()
	for recording in recordings:
		add_recording_panel(recording)

func _on_recording_saved(recording: Recording) -> void:
	add_recording_panel(recording)

func delete_all_panels() -> void:
	for child in get_children():
		child.queue_free()

func add_recording_panel(recording: Recording) -> void:
	var new_panel: SavedRecordingPanel = saved_recording_panel_scene.instantiate()
	new_panel.initialize(recording)
	add_child(new_panel)
