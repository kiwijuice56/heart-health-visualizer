class_name Main extends Node

@onready var record_button: Button = %CreateRecordingButton

@onready var recording_menu: RecordingMenu = %RecordingMenu

func _ready() -> void:
	# Connect UI components
	record_button.pressed.connect(_on_record_pressed)
	recording_menu.recording_requested.connect(_on_recording_requested)

func _on_recording_requested() -> void:
	if Ref.recorder.recording:
		Ref.recorder.stop_recording()
	else:
		Ref.recorder.start_recording()

func _on_record_pressed() -> void:
	recording_menu.enter()
