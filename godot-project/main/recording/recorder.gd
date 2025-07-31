class_name Recorder extends Node
## Handles the recording of PPG data to Recording resources.

## Length of PPG recordings, in samples.
@export_range(1, 120, 1, "suffix:seconds") var recording_length: int = 15

## Amount of samples to ignore when recording first starts. Used to reduce noise as the
## user presses the record button.
@export_range(0, 10, 1, "suffix:seconds") var initial_ignore_length: int = 2

# Modules
var ppg_analyzer: PpgAnalyzer
var camera: AndroidCamera

var recording: bool = false
var ignore_timer: SceneTreeTimer

# Current recording state
var ppg_signal_timestamps: PackedInt64Array
var ppg_signal: PackedInt32Array

signal recording_completed(recording: Recording)
signal ppg_frame_received(timestamp: int, ppg_value: int)

func _ready() -> void:
	# Initialize GDextension modules
	ppg_analyzer = PpgAnalyzer.new()
	
	# Initialize JNI module (camera)
	camera = AndroidCamera.new()
	camera.camera_frame.connect(_on_camera_frame)
	camera.request_camera_permissions()

func _on_camera_frame(timestamp: int, data: PackedByteArray, width: int, height: int) -> void:
	if not recording:
		return
	
	# Only add to the final output after a few seconds have gone by, to reduce jitter
	
	if is_instance_valid(ignore_timer) and ignore_timer.time_left > 0:
		return
	
	# Send image to recording progress menu
	# %RecordingProgressMenu.camera_texture_rect.texture = frame
	
	# Negation is necessary so that the signal isn't upside down
	var ppg_value: int = -ppg_analyzer.read_ppg_from_image(data, Rect2i(Vector2i(0, 0), Vector2i(width, height)))
	
	ppg_frame_received.emit(timestamp, ppg_value)
	
	ppg_signal.append(ppg_value)
	ppg_signal_timestamps.append(timestamp)

func start_recording() -> void:
	if not camera.request_camera_permissions():
		printerr("Camera permissions denied.")
		return
	
	assert(not recording)
	recording = true
	
	ignore_timer = get_tree().create_timer(initial_ignore_length, false)
	
	ppg_signal.clear()
	ppg_signal_timestamps.clear()
	camera.start_camera(300, 300, true)
	
	await get_tree().create_timer(recording_length + initial_ignore_length).timeout
	if recording:
		stop_recording()

func stop_recording() -> void:
	assert(recording)
	recording = false
	
	camera.stop_camera()
	
	var new_recording: Recording = create_recording()
	
	recording_completed.emit(new_recording)

func create_recording() -> Recording:
	var new_recording: Recording = Recording.new()
	
	new_recording.version = ProjectSettings.get_setting("application/config/version")
	new_recording.time = Time.get_datetime_dict_from_system()
	new_recording.recording_length = recording_length
	new_recording.raw_ppg_signal = ppg_signal.duplicate()
	new_recording.raw_ppg_signal_timestamps = ppg_signal_timestamps.duplicate()
	
	new_recording.processed_ppg_signal = ppg_analyzer.get_preprocessed_ppg_signal(ppg_signal, ppg_signal_timestamps)
	
	# Find the pulse scores and use them to calculate the total health score
	var scores: PackedFloat64Array = ppg_analyzer.calculate_pulse_scores(new_recording.processed_ppg_signal, 10)
	scores.sort()
	new_recording.pulse_scores = scores
	
	var median_score: float = 0
	if len(scores) > 0:
		@warning_ignore("integer_division")
		median_score = scores[len(scores) / 2]
	
	new_recording.health_score = median_score
	new_recording.heart_rate = ppg_analyzer.calculate_heart_rate(new_recording.processed_ppg_signal, 150)
	new_recording.heart_rate_variability = ppg_analyzer.calculate_heart_rate_variability(new_recording.processed_ppg_signal, 150)
	
	return new_recording
