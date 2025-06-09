class_name Recording extends Resource
## A data container for a recording session.

@export var version: String
@export var time: Dictionary

@export_group("Raw Data")
@export var raw_ppg_signal: PackedInt32Array
@export_range(10, 60, 1, "suffix:Hz") var sampling_frequency: int = 30

@export_group("Processed Data")
@export var health_score: float
