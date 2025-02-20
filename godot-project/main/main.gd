class_name Main extends Node

@onready var fractal_flame_renderer: FractalFlameRenderer = %FractalFlameRenderer
@onready var render_canvas: TextureRect = %RenderCanvas

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("render", false):
		render_canvas.texture = fractal_flame_renderer.render(Vector2i(512, 512), 128, 8192, 2048, 64)
