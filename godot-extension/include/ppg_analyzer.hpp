#pragma once

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/image.hpp>

#include "../matlab-generated/rtwtypes.h"
#include "../matlab-generated/coder_array.h"

#include <cstddef>
#include <cstdlib>

namespace godot {

class PpgAnalyzer : public Node {
	GDCLASS(PpgAnalyzer, Node)

private:

protected:
	static void _bind_methods();

public:
	const int HEART_SMOOTHING_SIZE_1 = 60;
	const int HEART_SMOOTHING_SIZE_2 = 10;
	const float PEAK_THRESHOLD = 0.0;

	PpgAnalyzer();
	~PpgAnalyzer();

	// Assumes RGBA8 format
	int read_ppg_from_image(PackedByteArray data, Rect2i bounding_box);

	// MATLAB functions:

	// Returns a resampled and preprocessed PPG signal at 150 Hz
	PackedFloat64Array get_preprocessed_ppg_signal(PackedInt32Array ppg_values, PackedInt64Array timestamps);

	// All 4 functions below return the cardiovascular health scores of all pulses in a *preprocessed* PPG signal, sampled at 150 Hz;
	// Each use a different algorithm with differently scaled scores, which are combined in the app into a final score
	PackedFloat64Array calculate_pulse_scores_fourier(PackedFloat64Array preprocessed_ppg_signal, int coefficient_count);
	PackedFloat64Array calculate_pulse_scores_linear_slope(PackedFloat64Array preprocessed_ppg_signal);
	PackedFloat64Array calculate_pulse_scores_rising_edge_area(PackedFloat64Array preprocessed_ppg_signal);
	PackedFloat64Array calculate_pulse_scores_peak_detection(PackedFloat64Array preprocessed_ppg_signal);

	// Returns the indices splitting the PPG signal into pulses
	PackedInt32Array get_ppg_indices(PackedFloat64Array preprocessed_ppg_signal);

	// Splits up the PPG signal and returns the average of all pulses
	PackedFloat64Array get_average_pulse(PackedFloat64Array preprocessed_ppg_signal);

	// Helper functions to convert data to and from Godot
	PackedFloat64Array matlab_scores_to_godot_scores(coder::array<double, 1U> matlab_scores);
	coder::array<double, 2U> godot_signal_to_matlab_signal(PackedFloat64Array godot_signal);

	// Manual functions:

	// Returns a smoothed version of `preprocessed_ppg_signal`
	PackedFloat64Array smoothed_ppg_signal(PackedFloat64Array preprocessed_ppg_signal, int window_size);

	// Returns the indices of peaks in `smoothed_signal`
	PackedInt32Array peak_finder(PackedFloat64Array smoothed_signal);

	// Returns heart rate in units of beats per minute
	float calculate_heart_rate(PackedFloat64Array preprocessed_ppg_signal, float sampling_frequency);

	// Returns heart rate variability in units of milliseconds
	float calculate_heart_rate_variability(PackedFloat64Array preprocessed_ppg_signal, float sampling_frequency);
};

}
