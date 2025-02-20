#pragma once

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/image_texture.hpp>

namespace godot {

class FractalFlameRenderer : public Node {
	GDCLASS(FractalFlameRenderer, Node)

private:
	PackedFloat64Array fractal_parameters;

protected:
	static void _bind_methods();

public:
	FractalFlameRenderer();
	~FractalFlameRenderer();

	Ref<ImageTexture> render(Vector2i image_size, double initial_radius, int sample_count, int iteration_count, int initial_iteration_ignore_count) const;

	void set_parameters(PackedFloat64Array new_parameters);
	PackedFloat64Array get_parameters() const;
};

}
