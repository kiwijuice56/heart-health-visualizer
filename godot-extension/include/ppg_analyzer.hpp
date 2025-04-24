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

	int read_ppg_from_image(Ref<Image> camera_frame, Rect2i bounding_box);

	// All methods assume `ppg_values` is an array of the PPG values evenly sampled at `sampling_frequency` hz

	// Returns a smoothed version of `ppg_values`
	PackedInt32Array smoothed_ppg_signal(PackedInt32Array ppg_values, int window_size);

	// Returns the indices of peaks in `ppg_values`
	PackedInt32Array peak_finder(PackedInt32Array ppg_values);

	// Returns heart rate in units of beats per minute
	float calculate_heart_rate(PackedInt32Array ppg_values, float sampling_frequency);

	// Returns heart rate variability in units of milliseconds
	float calculate_heart_rate_variability(PackedInt32Array ppg_values, float sampling_frequency);

	// Returns the mean PPG pulse waveform of a PPG signal
	// PackedFloat64Array calculate_mean_ppg_pulse_waveform(PackedInt32Array ppg_values, float sampling_frequency);

	// Given a single PPG pulse waveform (i.e. one heartbeat) as an array, return the A/B fourier coefficients
	// as a 2D array in the format [A, B]
	// TypedArray<TypedArray<float>> calculate_fourier_coefficients(PackedFloat64Array ppg_pulse_waveform, float sampling_frequency);


	void matlab_test();
};

}
