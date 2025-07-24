class_name Main extends Node

@onready var record_button: Button = %CreateRecordingButton
@onready var clear_button: Button = %ClearDataButton
@onready var about_button: Button = %AboutButton
@onready var select_folder_button: Button = %SelectFolderButton

@onready var recording_menu: RecordingMenu = %RecordingMenu
@onready var recording_progress_menu: Menu = %RecordingProgressMenu
@onready var about_menu: Menu = %AboutMenu
@onready var inspection_menu: InspectionMenu = %InspectionMenu

@onready var saved_recording_container: SavedRecordingContainer = %SavedRecordingContainer

func _ready() -> void:
	# Connect UI components
	record_button.pressed.connect(_on_record_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	about_button.pressed.connect(_on_about_pressed)
	select_folder_button.pressed.connect(_on_select_folder_pressed)
	
	recording_menu.recording_requested.connect(_on_recording_requested)
	
	saved_recording_container.panel_tapped.connect(_on_panel_tapped)
	
	OS.request_permissions()

func _on_panel_tapped(tapped_panel: SavedRecordingPanel) -> void:
	inspection_menu.initialize_information(tapped_panel.recording)
	inspection_menu.enter()

func _on_select_folder_pressed() -> void:
	Ref.file_selector.choose_folder()

func _on_about_pressed() -> void:
	about_menu.enter()

func _on_recording_requested() -> void:
	if not Ref.recorder.recording:
		recording_progress_menu.enter()
		
		Ref.recorder.start_recording()
		var recording: Recording = await Ref.recorder.recording_completed
		Ref.renderer.add_render_to_recording(recording)
		Ref.saver.save_recording(recording)
		
		inspection_menu.initialize_information(recording)
		inspection_menu.enter()
		
		await inspection_menu.exited
		
		recording_progress_menu.exit()
		recording_menu.exit()

func _on_record_pressed() -> void:
	recording_menu.enter()

func _on_clear_pressed() -> void:
	Ref.saver.clear_all_data()
