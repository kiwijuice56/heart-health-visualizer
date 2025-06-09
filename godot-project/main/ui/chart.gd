class_name Chart extends Control
## Debug script to plot a line from time-series data.

@export var line_color: Color = Color(0.5, 0.2, 0.9)
@export var peak_line_color: Color = Color(0.5, 0.2, 0.9)

@export var line_width: float = 1.0
@export var padding: float = 0.1

var stream: PackedInt32Array
var peaks: Dictionary[int, bool]

func _draw() -> void:
	if len(stream) == 0:
		return
	
	var max_y: float = -INF
	var min_y: float = +INF
	
	var y: PackedInt32Array = stream
	
	for val in y:
		max_y = max(max_y, val)
		min_y = min(min_y, val)
	
	# Normlize values to [0, 1] range
	var norm_y: PackedFloat64Array 
	norm_y.resize(len(y))
	for i in range(len(y)):
		norm_y[i] = float(y[i] - min_y) / (max_y - min_y)
	
	for i in range(1, len(norm_y)):
		var x_from: float = float(i - 1) / len(norm_y)
		var x_to: float = float(i) / len(norm_y)
		
		var from: Vector2 = Vector2(
			x_from * size.x, 
			size.y - fit(norm_y[i - 1], 0, 1, size.y))
		var to: Vector2 = Vector2(
			x_to * size.x, 
			size.y - fit(norm_y[i], 0, 1, size.y))
		from.y = from.y * (1.0 - padding) + size.y * padding / 2.0
		to.y = to.y * (1.0 - padding) + size.y * padding / 2.0
		
		draw_line(from, to, peak_line_color if i in peaks else line_color, line_width, true)

func fit(v: float, min_v: float, max_v: float, scalar: float) -> float:
	return (v - min_v) / float(max_v - min_v) * scalar

# Accepts time series signal + an array of indices in that signal that are peaks.
# Peaks are highlighted in a different color. You can pass in an empty array if this effect
# is not desired.
func plot(new_stream: PackedInt32Array, peak_indices: PackedInt32Array) -> void:
	stream = new_stream
	peaks = {}
	for peak in peak_indices:
		peaks[peak] = true
	queue_redraw()
