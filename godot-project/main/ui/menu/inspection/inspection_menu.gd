class_name InspectionMenu extends Menu

@export var x: int = 60
@export var y: int = 20
var show_advanced_info: bool = false

func _ready() -> void:
	super._ready()
	%AdvancedButton.pressed.connect(_on_advanced_pressed)

func _on_advanced_pressed() -> void:
	show_advanced_info = not show_advanced_info
	handle_advanced_info()

func initialize_information(recording: Recording) -> void:
	recording.heart_rate = Ref.recorder.ppg_analyzer.calculate_heart_rate(recording.processed_ppg_signal, 150)
	recording.heart_rate_variability = Ref.recorder.ppg_analyzer.calculate_heart_rate_variability(recording.processed_ppg_signal, 150)
	
	%Render.texture = recording.render
	%DateLabel.text = "%s/%s/%s" % [recording.time.year, recording.time.month, recording.time.day]
	%ScoreLabel.text = "Score: " + str(int(10 * recording.health_score))
	%HeartRateLabel.text = "Heart Rate: " + str(int(recording.heart_rate))
	%HeartRateVariabilityLabel.text = "Heart Rate Variability: %.2f" % recording.heart_rate_variability
	%PulseScoresLabel.text = "Pulse Scores: " + str(recording.pulse_scores)
	%Chart.timeWindow = Ref.recorder.recording_length
	%Chart.Initialize(recording.raw_ppg_signal, recording.raw_ppg_signal_timestamps)
	
	var preprocessed_timestamps: PackedInt64Array
	preprocessed_timestamps.resize(recording.processed_ppg_signal.size())
	for i in range(preprocessed_timestamps.size()):
		preprocessed_timestamps[i] = i
	var smoothed_signal: PackedFloat64Array =  Ref.recorder.ppg_analyzer.smoothed_ppg_signal(Ref.recorder.ppg_analyzer.smoothed_ppg_signal(recording.processed_ppg_signal, x), y)
	var peak_indices: PackedInt32Array = Ref.recorder.ppg_analyzer.peak_finder(smoothed_signal)
	%ProcessedChart.InitializeDebug(smoothed_signal, preprocessed_timestamps, peak_indices)
	print(peak_indices)
	show_advanced_info = false
	handle_advanced_info()

func handle_advanced_info() -> void:
	%PulseScoresLabel.visible = show_advanced_info
	%AdvancedButton.text = "Hide Advanced Info" if show_advanced_info else "Show Advanced Info"
