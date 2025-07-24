#pragma once

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/image.hpp>

#include "../matlab-generated/rtwtypes.h"
#include <cstddef>
#include <cstdlib>

namespace godot {

class PpgAnalyzer : public Node {
	GDCLASS(PpgAnalyzer, Node)

private:

protected:
	static void _bind_methods();

public:
	const int HEART_SMOOTHING_SIZE = 4;

	PpgAnalyzer();
	~PpgAnalyzer();

	// Assumes RGBA8 format
	int read_ppg_from_image(PackedByteArray data, Rect2i bounding_box);

	// All methods assume `ppg_values` is an array of the PPG values evenly sampled at `sampling_frequency` hz
	// Note that most of these functions are unused, since they were manually coded in C++ earlier on for debugging purposes;
	// Most analysis code happens in the MATLAB function call

	// Returns the cardiovascular health scores of all pulses in a PPG signal
	PackedFloat64Array calculate_pulse_scores(PackedInt32Array ppg_values);

	// Returns a smoothed version of `ppg_values`
	PackedInt32Array smoothed_ppg_signal(PackedInt32Array ppg_values, int window_size);

	// Returns the indices of peaks in `ppg_values`
	PackedInt32Array peak_finder(PackedInt32Array ppg_values);

	// Returns heart rate in units of beats per minute
	float calculate_heart_rate(PackedInt32Array ppg_values, float sampling_frequency);

	// Returns heart rate variability in units of milliseconds
	float calculate_heart_rate_variability(PackedInt32Array ppg_values, float sampling_frequency);
};

}
