class_name Main extends Node

@onready var fractal_flame_renderer: FractalFlameRenderer = %FractalFlameRenderer
@onready var render_canvas: TextureRect = %RenderCanvas

var fractal_parameters: PackedFloat64Array


var _plugin_name: String = "GodotAndroidCamera"
var _plugin_singleton

func _ready() -> void:
	# Initialize camera plugin
	if Engine.has_singleton(_plugin_name):
		_plugin_singleton = Engine.get_singleton(_plugin_name)
	else:
		printerr("Initialization error: unable to access the java logic")
	
	print(_plugin_singleton.requestCameraPermissions())
	
	# Initialize parameters
	
	fractal_parameters.resize(3)
	fractal_parameters.fill(0)
	
	# Connect debug UI components
	
	%RecordButton.pressed.connect(_on_record_pressed)
	
	for i in range(1, 4):
		get_node("%%P%dSlider" % i).value_changed.connect(_on_p_changed.bind(i))

func _on_record_pressed() -> void:
	print(_plugin_singleton.isCameraAvailable())
	_plugin_singleton.recordVideo()

func _on_p_changed(val: float, idx: int) -> void:
	fractal_parameters[idx - 1] = val
	fractal_flame_renderer.fractal_parameters = fractal_parameters

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("render", false):
		render_canvas.texture = fractal_flame_renderer.render(Vector2i(256, 256), 64, 64 * 32, 256, 8)

func _process(_delta: float) -> void:
	render_canvas.texture = fractal_flame_renderer.render(Vector2i(212, 212), 64, 1024, 128, 16)
