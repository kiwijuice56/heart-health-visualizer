class_name Recording extends Resource
## A data container for a recording session.

@export var version: String
@export var time: Dictionary

@export_group("Raw Data")
@export var raw_ppg_signal: PackedInt32Array
@export var raw_ppg_signal_timestamps: PackedInt64Array
@export_range(10, 120, 1, "suffix:seconds") var recording_length: int = 15

@export_group("Processed Data")
@export var health_score: float
@export var pulse_scores: PackedFloat64Array
@export var render: ImageTexture
