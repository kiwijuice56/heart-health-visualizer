#pragma once

#include <godot_cpp/classes/node.hpp>

namespace godot {

class FractalFlameRenderer : public Node {
	GDCLASS(FractalFlameRenderer, Node)

private:

protected:
	static void _bind_methods();

public:
	FractalFlameRenderer();
	~FractalFlameRenderer();
};

}
