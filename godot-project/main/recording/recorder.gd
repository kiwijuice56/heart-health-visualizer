class_name Recorder extends Node
## Handles the recording of PPG data to Recording resources.

@export_range(10, 60, 1, "suffix:Hz") var sampling_frequency: int = 30

## Length of PPG recordings, in samples.
@export_range(0, 6000, 10, "suffix:samples") var recording_length: int = 3600

## Amount of samples to ignore when recording first starts. Used to reduce noise as the
## user presses the record button.
@export_range(0, 360, 10, "suffix:samples") var initial_ignore_count: int = 60

# Modules
var ppg_analyzer: PpgAnalyzer
var camera: AndroidCamera

var recording: bool = false

# Current recording state
var ppg_signal: PackedInt32Array
var ppg_ignore_count: int = initial_ignore_count # Decrement as frames come in 

signal recording_completed

func _ready() -> void:
	# Initialize GDextension modules
	ppg_analyzer = PpgAnalyzer.new()
	
	# Initialize JNI module (camera)
	camera = AndroidCamera.new()
	camera.camera_frame.connect(_on_camera_frame)
	camera.request_camera_permissions()

func _on_camera_frame(frame: ImageTexture) -> void:
	if not recording:
		return
	
	if ppg_ignore_count > 0:
		ppg_ignore_count -= 1
		return
	
	# Add to signal
	var ppg_value: int = ppg_analyzer.read_ppg_from_image(frame.get_image(), Rect2i(Vector2i(0, 0), Vector2i(frame.get_width(), frame.get_height())))
	ppg_signal.append(ppg_value)
	
	# Calculate heart rate
	var _heart_rate: float = ppg_analyzer.calculate_heart_rate(ppg_signal, sampling_frequency)
	var _heart_rate_variability: float = ppg_analyzer.calculate_heart_rate_variability(ppg_signal, sampling_frequency)
	
	# Stop recording if length target is reached
	if len(ppg_signal) >= recording_length:
		stop_recording()

func start_recording() -> void:
	if not camera.request_camera_permissions():
		printerr("Camera permissions denied.")
		return
	
	assert(not recording)
	recording = true
	
	ppg_ignore_count = initial_ignore_count
	ppg_signal.clear()
	camera.start_camera(1080, 1080, sampling_frequency, true)

func stop_recording() -> void:
	assert(recording)
	recording = false
	
	camera.stop_camera()
	
	var new_recording: Recording = create_recording()
	Ref.saver.save_recording(new_recording)
	
	recording_completed.emit()

func create_recording() -> Recording:
	var new_recording: Recording = Recording.new()
	
	new_recording.version = ProjectSettings.get_setting("application/config/version")
	new_recording.time = Time.get_datetime_dict_from_system()
	new_recording.sampling_frequency = sampling_frequency
	new_recording.raw_ppg_signal = ppg_signal.duplicate()
	
	return new_recording
