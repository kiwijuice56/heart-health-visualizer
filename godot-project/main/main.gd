class_name Main extends Node

@onready var fractal_flame_renderer: FractalFlameRenderer = %FractalFlameRenderer
@onready var render_canvas: TextureRect = %RenderCanvas

var fractal_parameters: PackedFloat64Array

func _ready() -> void:
	fractal_parameters.resize(2)
	fractal_parameters.fill(0)
	
	%P1Slider.value_changed.connect(_on_p1_changed)
	%P2Slider.value_changed.connect(_on_p2_changed)

func _on_p1_changed(val: float) -> void:
	fractal_parameters[0] = val
	fractal_flame_renderer.fractal_parameters = fractal_parameters

func _on_p2_changed(val: float) -> void:
	fractal_parameters[1] = val
	fractal_flame_renderer.fractal_parameters = fractal_parameters

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("render", false):
		render_canvas.texture = fractal_flame_renderer.render(Vector2i(256, 256), 64, 64 * 32, 256, 8)

func _process(delta: float) -> void:
	render_canvas.texture = fractal_flame_renderer.render(Vector2i(256, 256), 64, 1024, 128, 8)
