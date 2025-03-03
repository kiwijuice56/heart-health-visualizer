#pragma once

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/image.hpp>

namespace godot {

class PpgReader : public Node {
	GDCLASS(PpgReader, Node)

private:

protected:
	static void _bind_methods();

public:
	PpgReader();
	~PpgReader();

	int read_ppg_from_image(Ref<Image> camera_frame, Rect2i bounding_box);
};

}
