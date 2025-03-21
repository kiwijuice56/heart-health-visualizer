class_name Main extends Node

@onready var render_canvas: TextureRect = %RenderCanvas
@onready var camera_canvas: TextureRect = %CameraCanvas

@onready var raw_ppg_chart: Chart = %RawPpgChart
@onready var smooth_ppg_chart: Chart = %SmoothPpgChart

@onready var record_button: Button = %RecordButton
@onready var render_button: Button = %RenderButton

var fractal_flame_renderer: FractalFlameRenderer 
var ppg_analyzer: PpgAnalyzer
var camera: AndroidCamera

var fractal_parameters: PackedFloat64Array
var recording: bool = false
var rendering: bool = false

var ppg_signal: PackedInt32Array
var ppg_buffer: Array[int] = []
var ppg_ignore_count: int = ppg_ignore_amount

const ppg_ignore_amount: int = 16
const signal_size: int = 150
const smooth_window_size: int = 4
const ppg_buffer_size: int = 64

func _ready() -> void:
	set_process(rendering)
	
	# Initialize GDextension modules
	fractal_flame_renderer = FractalFlameRenderer.new()
	ppg_analyzer = PpgAnalyzer.new()
	
	# Initialize parameters
	fractal_parameters.resize(3)
	fractal_parameters.fill(0)
	
	# Initialize JNI module (camera)
	camera = AndroidCamera.new()
	camera.camera_frame.connect(_on_camera_frame)
	
	# Connect debug UI components
	record_button.pressed.connect(_on_record_pressed)
	render_button.pressed.connect(_on_render_pressed)
	for i in range(1, 4):
		get_node("%%P%dSlider" % i).value_changed.connect(_on_p_changed.bind(i))

func _on_camera_frame(frame: ImageTexture) -> void:
	if ppg_ignore_count > 0:
		ppg_ignore_count -= 1
		return
	
	camera_canvas.texture = frame
	
	# Add to signal
	var ppg_value: int = ppg_analyzer.read_ppg_from_image(frame.get_image(), Rect2i(Vector2i(0, 0), Vector2i(frame.get_width(), frame.get_height())))
	ppg_buffer.append(ppg_value)

	if len(ppg_buffer) > ppg_buffer_size:
		ppg_signal.append(ppg_buffer.pop_front())
	
	if len(ppg_signal) > signal_size:
		ppg_signal.remove_at(0)
	
	# Plot signals
	
	if len(ppg_signal) > 0:
		raw_ppg_chart.plot(ppg_signal)
	
	if len(ppg_signal) > smooth_window_size:
		var smooth_ppg_signal: PackedInt32Array = ppg_analyzer.smoothed_ppg_signal(ppg_signal, smooth_window_size)
		smooth_ppg_chart.plot(smooth_ppg_signal.slice(smooth_window_size))
	

func _on_record_pressed() -> void:
	if not camera.request_camera_permissions():
		printerr("Camera permissions denied.")
		return
	recording = not recording
	if recording:
		ppg_ignore_count = ppg_ignore_amount
		camera.start_camera(1080, 1080, 60, true)
	else:
		camera.stop_camera()

func _on_render_pressed() -> void:
	rendering = not rendering
	set_process(rendering)

func _on_p_changed(val: float, idx: int) -> void:
	fractal_parameters[idx - 1] = val
	fractal_flame_renderer.fractal_parameters = fractal_parameters

func _process(_delta: float) -> void:
	render_canvas.texture = fractal_flame_renderer.render(Vector2i(212, 212), 64, 1024, 128, 16)
