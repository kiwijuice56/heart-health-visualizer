class_name Main extends Node

@onready var record_button: Button = %CreateRecordingButton
@onready var clear_button: Button = %ClearDataButton
@onready var about_button: Button = %AboutButton

@onready var recording_menu: RecordingMenu = %RecordingMenu
@onready var recording_progress_menu: Menu = %RecordingProgressMenu
@onready var about_menu: Menu = %AboutMenu

func _ready() -> void:
	# Connect UI components
	record_button.pressed.connect(_on_record_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	about_button.pressed.connect(_on_about_pressed)
	
	recording_menu.recording_requested.connect(_on_recording_requested)

func _on_about_pressed() -> void:
	about_menu.enter()

func _on_recording_requested() -> void:
	if not Ref.recorder.recording:
		recording_progress_menu.enter()
		
		Ref.recorder.start_recording()
		var recording: Recording = await Ref.recorder.recording_completed
		Ref.renderer.add_render_to_recording(recording)
		Ref.saver.save_recording(recording)
		
		recording_progress_menu.exit()
		recording_menu.exit()

func _on_record_pressed() -> void:
	recording_menu.enter()

func _on_clear_pressed() -> void:
	Ref.saver.clear_all_data()
