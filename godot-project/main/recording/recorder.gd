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
	const padding_amount: float = 0.2
	var padding_x: int = int(width * padding_amount)
	var padding_y: int = int(height * padding_amount)
	var ppg_value: int = -ppg_analyzer.read_ppg_from_image(data, Rect2i(Vector2i(padding_x, padding_y), Vector2i(max(0, width - padding_x), max(0, height - padding_y))))
	
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
	# These were observed experimentally and are used to normalize the scores into roughly the same scale
	# because the original units are arbitrary -- these can be updated to weigh certain scores more than others
	const median_fourier: float = 1.98
	const median_linear_slope: float = 0.01
	const median_rising_edge_area: float = 0.0005
	const median_peak_detection: float = 0.5
	
	const iqr_fourier: float = 0.35
	const iqr_linear_slope: float = 0.003
	const iqr_rising_edge_area: float = 0.0005
	const iqr_peak_detection: float = 0.5
	
	var new_recording: Recording = Recording.new()
	
	new_recording.version = ProjectSettings.get_setting("application/config/version")
	new_recording.time = Time.get_datetime_dict_from_system()
	new_recording.recording_length = recording_length
	new_recording.raw_ppg_signal = ppg_signal.duplicate()
	new_recording.raw_ppg_signal_timestamps = ppg_signal_timestamps.duplicate()
	
	new_recording.processed_ppg_signal = ppg_analyzer.get_preprocessed_ppg_signal(ppg_signal, ppg_signal_timestamps)
	
	# Calculate HR and HRV using algorithms implemented in C++
	new_recording.heart_rate = ppg_analyzer.calculate_heart_rate(new_recording.processed_ppg_signal, 150)
	new_recording.heart_rate_variability = ppg_analyzer.calculate_heart_rate_variability(new_recording.processed_ppg_signal, 150)
	
	# Find the pulse scores and use them to calculate the total health score using algorithms implemented in MATLAB
	new_recording.pulse_scores_fourier = ppg_analyzer.calculate_pulse_scores_fourier(new_recording.processed_ppg_signal, 20)
	new_recording.pulse_scores_linear_slope = ppg_analyzer.calculate_pulse_scores_linear_slope(new_recording.processed_ppg_signal)
	new_recording.pulse_scores_rising_edge_area = ppg_analyzer.calculate_pulse_scores_rising_edge_area(new_recording.processed_ppg_signal)
	new_recording.pulse_scores_peak_detection = ppg_analyzer.calculate_pulse_scores_peak_detection(new_recording.processed_ppg_signal)
	
	var sorted_pulse_scores_fourier: PackedFloat64Array = new_recording.pulse_scores_fourier.duplicate()
	var sorted_pulse_scores_linear_slope: PackedFloat64Array = new_recording.pulse_scores_linear_slope.duplicate()
	var sorted_pulse_scores_rising_edge_area: PackedFloat64Array = new_recording.pulse_scores_rising_edge_area.duplicate()
	var sorted_pulse_scores_peak_detection: PackedFloat64Array = new_recording.pulse_scores_peak_detection.duplicate()
	
	sorted_pulse_scores_fourier.sort()
	sorted_pulse_scores_linear_slope.sort()
	sorted_pulse_scores_rising_edge_area.sort()
	sorted_pulse_scores_peak_detection.sort()
	
	new_recording.overall_score_fourier = 0.0
	if len(sorted_pulse_scores_fourier) > 0:
		@warning_ignore("integer_division")
		new_recording.overall_score_fourier = sorted_pulse_scores_fourier[len(sorted_pulse_scores_fourier) / 2]
		new_recording.overall_score_fourier = normalize_score(new_recording.overall_score_fourier, median_fourier, iqr_fourier)
	
	new_recording.overall_score_linear_slope = 0.0
	if len(sorted_pulse_scores_linear_slope) > 0:
		@warning_ignore("integer_division")
		new_recording.overall_score_linear_slope = sorted_pulse_scores_linear_slope[len(sorted_pulse_scores_linear_slope) / 2]
		new_recording.overall_score_linear_slope = normalize_score(new_recording.overall_score_linear_slope, median_linear_slope, iqr_linear_slope)
	
	new_recording.overall_score_rising_edge_area = 0.0
	if len(sorted_pulse_scores_rising_edge_area) > 0:
		@warning_ignore("integer_division")
		new_recording.overall_score_rising_edge_area = sorted_pulse_scores_rising_edge_area[len(sorted_pulse_scores_rising_edge_area) / 2]
		new_recording.overall_score_rising_edge_area = normalize_score(new_recording.overall_score_rising_edge_area, median_rising_edge_area, iqr_rising_edge_area)
	
	new_recording.overall_score_peak_detection = 0.0
	if len(sorted_pulse_scores_peak_detection) > 0:
		@warning_ignore("integer_division")
		new_recording.overall_score_peak_detection = sorted_pulse_scores_peak_detection[len(sorted_pulse_scores_peak_detection) / 2]
		new_recording.overall_score_peak_detection = normalize_score(new_recording.overall_score_peak_detection, median_peak_detection, iqr_peak_detection)
	
	new_recording.health_score = (new_recording.overall_score_fourier + new_recording.overall_score_linear_slope + new_recording.overall_score_peak_detection + new_recording.overall_score_peak_detection) / 4.0
	
	return new_recording

func normalize_score(score: float, median: float, iqr: float) -> float:
	var normalized_score: float = (score - median) / (0.5 * iqr) # ~[-1, 1]
	return (normalized_score + 1.0) / 2.0 # ~[0, 1]
