class_name Recording extends Resource
## A data container for a recording session.

@export var version: String
@export var time: Dictionary
@export var user_id: String

@export_group("Raw Data")
@export var raw_ppg_signal: PackedInt32Array
@export var raw_ppg_signal_timestamps: PackedInt64Array
@export_range(10, 120, 1, "suffix:seconds") var recording_length: int = 15

@export_group("Processed Data")
@export var processed_ppg_signal: PackedFloat64Array # Evenly spaced 150 Hz signal
@export var pulse_indices: PackedInt32Array
@export var average_ppg_pulse: PackedFloat64Array
@export var health_score: float
@export var heart_rate: float
@export var heart_rate_variability: float
@export var pulse_scores_fourier: PackedFloat64Array
@export var overall_score_fourier: float
@export var pulse_scores_linear_slope: PackedFloat64Array
@export var overall_score_linear_slope: float
@export var pulse_scores_rising_edge_area: PackedFloat64Array
@export var overall_score_rising_edge_area: float
@export var pulse_scores_peak_detection: PackedFloat64Array
@export var overall_score_peak_detection: float

@export_group("Texture Data")
@export var render: ImageTexture
