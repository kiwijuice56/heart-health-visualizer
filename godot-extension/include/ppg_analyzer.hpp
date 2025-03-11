#pragma once

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/image.hpp>

namespace godot {

class PpgAnalyzer : public Node {
	GDCLASS(PpgAnalyzer, Node)

private:

protected:
	static void _bind_methods();

public:
	PpgAnalyzer();
	~PpgAnalyzer();

	int read_ppg_from_image(Ref<Image> camera_frame, Rect2i bounding_box);

	// All methods assume `ppg_values` is an array of the PPG value evenly sampled at `sampling_frequency` hz
	PackedInt32Array smoothed_ppg_signal(PackedInt32Array ppg_values, int window_size);
	float calculate_heart_rate(PackedInt32Array ppg_values, float sampling_frequency);
	float calculate_heart_rate_variability(PackedInt32Array ppg_values, float sampling_frequency);
};

}
