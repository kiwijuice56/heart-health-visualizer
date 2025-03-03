class_name Main extends Node

@onready var render_canvas: TextureRect = %RenderCanvas
@onready var camera_canvas: TextureRect = %CameraCanvas

@onready var ppg_chart: Chart = %PpgChart
@onready var record_button: Button = %RecordButton

var fractal_flame_renderer: FractalFlameRenderer 
var ppg_reader: PpgReader
var camera: AndroidCamera

var fractal_parameters: PackedFloat64Array
var recording: bool = false

func _ready() -> void:
	# Initialize GDextension modules
	fractal_flame_renderer = FractalFlameRenderer.new()
	ppg_reader = PpgReader.new()
	
	# Initialize parameters
	fractal_parameters.resize(3)
	fractal_parameters.fill(0)
	
	# Initialize JNI module (camera)
	camera = AndroidCamera.new()
	camera.camera_frame.connect(_on_camera_frame)
	
	# Connect debug UI components
	record_button.pressed.connect(_on_record_pressed)
	for i in range(1, 4):
		get_node("%%P%dSlider" % i).value_changed.connect(_on_p_changed.bind(i))

func _on_camera_frame(frame: ImageTexture) -> void:
	camera_canvas.texture = frame
	var ppg_val: int = ppg_reader.read_ppg_from_image(frame.get_image(), Rect2i(Vector2i(128, 128), Vector2i(768, 768)))
	ppg_chart.add_point(ppg_val, Time.get_unix_time_from_system())

func _on_record_pressed() -> void:
	if not camera.request_camera_permissions():
		printerr("Camera permissions denied.")
		return
	recording = not recording
	if recording:
		camera.start_camera(1024, 1024, 30, true)
	else:
		camera.stop_camera()

func _on_p_changed(val: float, idx: int) -> void:
	fractal_parameters[idx - 1] = val
	fractal_flame_renderer.fractal_parameters = fractal_parameters

func _process(_delta: float) -> void:
	render_canvas.texture = fractal_flame_renderer.render(Vector2i(212, 212), 64, 1024, 128, 16)
