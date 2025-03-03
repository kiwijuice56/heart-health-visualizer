class_name Chart extends Control

## Measured in seconds.
@export var time_window: float = 8 

@export var line_color: Color = Color(0.5, 0.2, 0.9)
@export var line_width: float = 1.0
@export var padding: float = 0.1

var stream: PackedInt64Array
var timestamps: PackedFloat64Array

func _ready() -> void:
	stream = PackedInt64Array()
	timestamps = PackedFloat64Array()

func _draw() -> void:
	if len(stream) == 0:
		return
	
	var max_y: float = -INF
	var min_y: float = +INF
	
	var y: PackedInt64Array = stream
	var x: PackedFloat64Array = timestamps
	
	for val in y:
		max_y = max(max_y, val)
		min_y = min(min_y, val)
	
	# Normlize values to [0, 1] range
	var norm_y: PackedFloat64Array 
	norm_y.resize(len(y))
	for i in range(len(y)):
		norm_y[i] = float(y[i] - min_y) / (max_y - min_y)
	
	var min_x: float = Time.get_unix_time_from_system() - time_window
	var max_x: = Time.get_unix_time_from_system()
	
	for i in range(1, len(norm_y)):
		if x[i - 1] < min_x or x[i - 1] > max_x:
			continue 
		var from: Vector2 = Vector2(
			fit(x[i - 1], min_x, max_x, size.x), 
			size.y - fit(norm_y[i - 1], 0, 1, size.y))
		var to: Vector2 = Vector2(
			fit(x[i], min_x, max_x, size.x), 
			size.y - fit(norm_y[i], 0, 1, size.y))
		from.y = from.y * (1.0 - padding) + size.y * padding / 2.0
		to.y = to.y * (1.0 - padding) + size.y * padding / 2.0
		to.x = min(size.x, to.x)
		draw_line(from, to, line_color, line_width, true)

func _process(_delta: float) -> void:
	queue_redraw()

func initialize(annotation: String) -> void:
	%AnnotationLabel.text = annotation

func fit(v: float, min_v: float, max_v: float, scalar: float) -> float:
	return (v - min_v) / float(max_v - min_v) * scalar

func add_point(value: int, timestamp: float) -> void:
	stream.append(value)
	timestamps.append(timestamp)
	
	while timestamps[-1] - timestamps[0] > time_window:
		stream.remove_at(0)
		timestamps.remove_at(0)
