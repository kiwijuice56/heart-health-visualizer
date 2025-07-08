class_name Recorder extends Node
## Handles the recording of PPG data to Recording resources.

## Length of PPG recordings, in samples.
@export_range(1, 120, 1, "suffix:seconds") var recording_length: int = 15

## Amount of samples to ignore when recording first starts. Used to reduce noise as the
## user presses the record button.
@export_range(0, 360, 10, "suffix:samples") var initial_ignore_count: int = 60

# Modules
var ppg_analyzer: PpgAnalyzer
var camera: AndroidCamera

var recording: bool = false

# Current recording state
var ppg_signal_timestamps: PackedInt64Array
var ppg_signal: PackedInt32Array
var ppg_ignore_count: int = initial_ignore_count # Decrement as frames come in 

signal recording_completed(recording: Recording)

func _ready() -> void:
	# Initialize GDextension modules
	ppg_analyzer = PpgAnalyzer.new()
	
	# Initialize JNI module (camera)
	camera = AndroidCamera.new()
	camera.camera_frame.connect(_on_camera_frame)
	camera.request_camera_permissions()

func _on_camera_frame(timestamp: int, frame: ImageTexture) -> void:
	if not recording:
		return
	
	# Send image to recording progress menu
	%RecordingProgressMenu.camera_texture_rect.texture = frame
	
	if ppg_ignore_count > 0:
		ppg_ignore_count -= 1
		return
	
	# Add to signal
	var ppg_value: int = ppg_analyzer.read_ppg_from_image(frame.get_image(), Rect2i(Vector2i(0, 0), Vector2i(frame.get_width(), frame.get_height())))
	ppg_signal.append(ppg_value)
	
	ppg_signal_timestamps.append(timestamp)

func start_recording() -> void:
	if not camera.request_camera_permissions():
		printerr("Camera permissions denied.")
		return
	
	assert(not recording)
	recording = true
	
	ppg_ignore_count = initial_ignore_count
	ppg_signal.clear()
	
	camera.start_camera(256, 256, false)
	await get_tree().create_timer(recording_length).timeout
	if recording:
		stop_recording()

func stop_recording() -> void:
	assert(recording)
	recording = false
	
	camera.stop_camera()
	
	var new_recording: Recording = create_recording()
	
	# Final score is the median of all pulse scores
	var scores: PackedFloat64Array = ppg_analyzer.calculate_pulse_scores(ppg_signal)
	scores.sort()
	@warning_ignore("integer_division")
	var median_score: float = scores[len(scores) / 2]
	
	new_recording.health_score = median_score
	
	recording_completed.emit(new_recording)

func create_recording() -> Recording:
	var new_recording: Recording = Recording.new()
	
	new_recording.version = ProjectSettings.get_setting("application/config/version")
	new_recording.time = Time.get_datetime_dict_from_system()
	new_recording.recording_length = recording_length
	new_recording.raw_ppg_signal = ppg_signal.duplicate()
	new_recording.raw_ppg_signal_timestamps = ppg_signal_timestamps.duplicate()
	
	return new_recording
