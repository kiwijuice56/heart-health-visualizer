class_name Main extends Node

@onready var record_button: Button = %CreateRecordingButton

@onready var recording_menu: RecordingMenu = %RecordingMenu
@onready var recording_progress_menu: Menu = %RecordingProgressMenu

func _ready() -> void:
	# Connect UI components
	record_button.pressed.connect(_on_record_pressed)
	recording_menu.recording_requested.connect(_on_recording_requested)

func _on_recording_requested() -> void:
	if not Ref.recorder.recording:
		recording_progress_menu.enter()
		Ref.recorder.start_recording()
		await Ref.recorder.recording_completed
		recording_progress_menu.exit()
		recording_menu.exit()

func _on_record_pressed() -> void:
	recording_menu.enter()
