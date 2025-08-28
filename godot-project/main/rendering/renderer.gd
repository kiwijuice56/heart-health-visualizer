class_name Renderer extends Node
## Handles the fractal rendering of Recording resources.

@export var image_size: Vector2i = Vector2i(512, 512)

# Modules
var fractal_flame: FractalFlameRenderer

func _ready() -> void:
	fractal_flame = FractalFlameRenderer.new()

func render_recording(recording: Recording) -> ImageTexture:
	fractal_flame.fractal_parameters = PackedFloat64Array([
		recording.overall_score_fourier, 
		recording.overall_score_linear_slope + recording.overall_score_rising_edge_area, 
		recording.overall_score_peak_detection
	])
	return fractal_flame.render(image_size, 200, 4096, 512, 32)

func add_render_to_recording(recording: Recording) -> void:
	recording.render = render_recording(recording)
