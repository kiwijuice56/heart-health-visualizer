class_name RecordingProgressMenu extends Menu

@onready var camera_texture_rect: TextureRect = %CameraTexture
@onready var progress_bar: ProgressBar = %ProgressBar

func _ready() -> void:
	super._ready()
	Ref.recorder.ppg_frame_received.connect(_on_ppg_frame_received)

func _on_ppg_frame_received(timestamp: int, ppg_value: int) -> void:
	%Chart.AddPoint(float(ppg_value), timestamp)

func enter() -> void:
	super.enter()
	%Chart.Reset()
