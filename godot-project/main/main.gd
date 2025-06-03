class_name Main extends Node

@onready var recorder: Recorder = %Recorder
@onready var record_button: Button = %RecordButton

func _ready() -> void:
	# Connect UI components
	record_button.pressed.connect(_on_record_pressed)

func _on_record_pressed() -> void:
	if recorder.recording:
		recorder.stop_recording()
	else:
		recorder.start_recording()
