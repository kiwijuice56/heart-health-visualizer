class_name Main extends Node

@onready var fractal_flame_renderer: FractalFlameRenderer = %FractalFlameRenderer
@onready var render_canvas: TextureRect = %RenderCanvas

var fractal_parameters: PackedFloat64Array


func _ready() -> void:
	# Initialize parameters
	
	fractal_parameters.resize(3)
	fractal_parameters.fill(0)
	
	# Connect debug UI components
	
	%RecordButton.pressed.connect(_on_record_pressed)
	
	for i in range(1, 4):
		get_node("%%P%dSlider" % i).value_changed.connect(_on_p_changed.bind(i))

func _on_record_pressed() -> void:
	pass

func _on_p_changed(val: float, idx: int) -> void:
	fractal_parameters[idx - 1] = val
	fractal_flame_renderer.fractal_parameters = fractal_parameters

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("render", false):
		render_canvas.texture = fractal_flame_renderer.render(Vector2i(256, 256), 64, 64 * 32, 256, 8)

func _process(_delta: float) -> void:
	render_canvas.texture = fractal_flame_renderer.render(Vector2i(212, 212), 64, 1024, 128, 16)
