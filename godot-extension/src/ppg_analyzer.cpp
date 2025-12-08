#include "../include/ppg_analyzer.hpp"

#include "../matlab-generated/preprocess_ppg_signal.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void PpgAnalyzer::_bind_methods() {
    ClassDB::bind_method(D_METHOD("read_ppg_from_image", "camera_frame", "bounding_box"), &PpgAnalyzer::read_ppg_from_image);
    ClassDB::bind_method(D_METHOD("smoothed_ppg_signal", "ppg_values", "window_size"), &PpgAnalyzer::smoothed_ppg_signal);
    ClassDB::bind_method(D_METHOD("peak_finder", "ppg_values"), &PpgAnalyzer::peak_finder);

    ClassDB::bind_method(D_METHOD("calculate_heart_rate", "ppg_values", "sampling_frequency"), &PpgAnalyzer::calculate_heart_rate);
    ClassDB::bind_method(D_METHOD("calculate_heart_rate_variability", "ppg_values", "sampling_frequency"), &PpgAnalyzer::calculate_heart_rate_variability);
    ClassDB::bind_method(D_METHOD("calculate_pulse_scores_fourier", "preprocessed_ppg_signal", "coefficient_count"), &PpgAnalyzer::calculate_pulse_scores_fourier);
    ClassDB::bind_method(D_METHOD("calculate_pulse_scores_linear_slope", "preprocessed_ppg_signal"), &PpgAnalyzer::calculate_pulse_scores_linear_slope);
    ClassDB::bind_method(D_METHOD("calculate_pulse_scores_rising_edge_area", "preprocessed_ppg_signal"), &PpgAnalyzer::calculate_pulse_scores_rising_edge_area);
    ClassDB::bind_method(D_METHOD("calculate_pulse_scores_peak_detection", "preprocessed_ppg_signal"), &PpgAnalyzer::calculate_pulse_scores_peak_detection);
    ClassDB::bind_method(D_METHOD("get_preprocessed_ppg_signal", "ppg_values", "timestamps"), &PpgAnalyzer::get_preprocessed_ppg_signal);
    ClassDB::bind_method(D_METHOD("get_ppg_indices", "processed_ppg_values"), &PpgAnalyzer::get_ppg_indices);
}

PpgAnalyzer::PpgAnalyzer() {

}

PpgAnalyzer::~PpgAnalyzer() {

}

int PpgAnalyzer::read_ppg_from_image(PackedByteArray data, Rect2i bounding_box) {
    const int start_y = bounding_box.get_position().y;
    const int end_y = start_y + bounding_box.get_size().y;

    const int start_x = bounding_box.get_position().x;
    const int end_x = start_x + bounding_box.get_size().x;

    int ppg_point = 0;

    for (int y = start_y; y < end_y; y++) {
        for (int x = start_x; x < end_x; x++) {
            int64_t red = data[4 * (x + y * (end_x - start_x))];
            ppg_point += red;
        }
    }

    return ppg_point;
}

PackedFloat64Array PpgAnalyzer::smoothed_ppg_signal(PackedFloat64Array preprocessed_ppg_signal, int window_size) {
    PackedFloat64Array smoothed_signal;
    smoothed_signal.resize(preprocessed_ppg_signal.size());

    double window_sum = 0;
    for (int i = 0; i < preprocessed_ppg_signal.size(); i++) {
        window_sum += preprocessed_ppg_signal[i];

        smoothed_signal[i] = window_sum / window_size;

        if (i >= window_size) {
            window_sum -= preprocessed_ppg_signal[i - window_size];
        }
    }

    return smoothed_signal;
}

PackedInt32Array PpgAnalyzer::peak_finder(PackedFloat64Array smoothed_signal) {
    PackedInt32Array peak_indices;

    for (int i = 1; i < smoothed_signal.size() - 1; i++) {
        if (smoothed_signal[i] - smoothed_signal[i - 1] > PEAK_THRESHOLD && smoothed_signal[i] - smoothed_signal[i + 1] > PEAK_THRESHOLD) {
            peak_indices.append(i);
        }
    }

    return peak_indices;
}

float PpgAnalyzer::calculate_heart_rate(PackedFloat64Array preprocessed_ppg_signal, float sampling_frequency) {
    // Since we only care about peaks, we want to smooth away the dicrotic notch
    // and any noise with a heavy smoothing filter
    const PackedFloat64Array smoothed_signal = smoothed_ppg_signal(smoothed_ppg_signal(preprocessed_ppg_signal, HEART_SMOOTHING_SIZE_1), HEART_SMOOTHING_SIZE_2);
    const PackedInt32Array peak_indices = peak_finder(smoothed_signal);

    if (peak_indices.size() <= 1) {
        return 0.0;
    }

    double interbeat_interval_sum = 0.0;
    for (int i = 1; i < peak_indices.size(); i++) {
        double index_distance = peak_indices[i] - peak_indices[i - 1];
        interbeat_interval_sum += index_distance / sampling_frequency;
    }

    double average_beat_length = interbeat_interval_sum / (peak_indices.size() - 1);

    return 60.0 / average_beat_length;
}

float PpgAnalyzer::calculate_heart_rate_variability(PackedFloat64Array preprocessed_ppg_signal, float sampling_frequency) {
    const PackedFloat64Array smoothed_signal = smoothed_ppg_signal(smoothed_ppg_signal(preprocessed_ppg_signal, HEART_SMOOTHING_SIZE_1), HEART_SMOOTHING_SIZE_2);
    const PackedInt32Array peak_indices = peak_finder(smoothed_signal);

    if (peak_indices.size() <= 1) {
        return 0.0;
    }

    // Calculate the mean interbeat interval
    double interbeat_interval_sum = 0.0;
    for (int i = 1; i < peak_indices.size(); i++) {
        double index_distance = peak_indices[i] - peak_indices[i - 1];
        double interbeat_interval = index_distance / sampling_frequency;
        interbeat_interval_sum += interbeat_interval;
    }
    const double mean_interbeat_interval = interbeat_interval_sum / (peak_indices.size() - 1);

    // Calculate the variance of interbeat intervals
    double variance = 0.0;
    for (int i = 1; i < peak_indices.size(); i++) {
        double index_distance = peak_indices[i] - peak_indices[i - 1];
        double interbeat_interval = index_distance / sampling_frequency;

        variance += (interbeat_interval - mean_interbeat_interval) * (interbeat_interval - mean_interbeat_interval);
    }

    // s to ms
    return 1000.0 * UtilityFunctions::sqrt(variance / (peak_indices.size() - 1));
}

coder::array<double, 2U> PpgAnalyzer::godot_signal_to_matlab_signal(PackedFloat64Array godot_signal) {
    coder::array<double, 2U> matlab_ppg_signal;

    matlab_ppg_signal.set_size(1, godot_signal.size());

    for (int i = 0; i < godot_signal.size(); i++) {
        matlab_ppg_signal[i] = godot_signal[i];
    }

    return matlab_ppg_signal;
}

PackedFloat64Array PpgAnalyzer::matlab_scores_to_godot_scores(coder::array<double, 1U> matlab_scores) {
    PackedFloat64Array output_scores;
    output_scores.resize(matlab_scores.size(0));

    for (int i = 0; i < matlab_scores.size(0); i++) {
        output_scores[i] = matlab_scores[i];
    }

    return output_scores;
}

// This function is a wrapper around the MATlAB autogenerated C++ code
// See README for link to the MATLAB repository
PackedFloat64Array PpgAnalyzer::get_preprocessed_ppg_signal(PackedInt32Array ppg_values, PackedInt64Array timestamps) {
    // Copy data into MATLAB format
    coder::array<double, 2U> matlab_ppg_values;
    coder::array<int64m_T, 2U> matlab_timestamps;
    matlab_ppg_values.set_size(1, ppg_values.size());
    matlab_timestamps.set_size(1, timestamps.size());

    for (int i = 0; i < ppg_values.size(); i++) {
        matlab_ppg_values[i] = (double) ppg_values[i];
    }

    for (int i = 0; i < timestamps.size(); i++) {
        matlab_timestamps[i].chunks[0] = (uint32_t) (timestamps[i] & 0xFFFFFFFF);
        matlab_timestamps[i].chunks[1] = (uint32_t) ((timestamps[i] >> 32) & 0xFFFFFFFF);
    }

    // Call main function
    coder::array<double, 2U> matlab_processed_ppg_signal;
    preprocess_ppg_signal(matlab_ppg_values, matlab_timestamps, matlab_processed_ppg_signal);

    // Copy data into Godot format
    PackedFloat64Array output_signal;
    output_signal.resize(matlab_processed_ppg_signal.size(1));

    for (int i = 0; i < matlab_processed_ppg_signal.size(1); i++) {
        output_signal[i] = matlab_processed_ppg_signal[i];
    }

    return output_signal;
}

PackedInt32Array PpgAnalyzer::get_ppg_indices(PackedFloat64Array preprocessed_ppg_signal) {
    coder::array<double, 2U> matlab_ppg_signal = godot_signal_to_matlab_signal(preprocessed_ppg_signal);

    coder::array<double, 2U> matab_indices;
    split_ppg_signal(matlab_ppg_signal, matab_indices);


    PackedInt32Array output_indices;
    output_indices.resize(matab_indices.size(1));

    for (int i = 0; i < matab_indices.size(1); i++) {
        output_indices[i] = (int) matab_indices[i];
    }

    return output_indices;
}

// This function is a wrapper around the MATlAB autogenerated C++ code
// See README for link to the MATLAB repository
PackedFloat64Array PpgAnalyzer::calculate_pulse_scores_fourier(PackedFloat64Array preprocessed_ppg_signal, int coefficient_count) {
    int64m_T matlab_coefficient_count;
    matlab_coefficient_count.chunks[0] = (uint32_t) (coefficient_count & 0xFFFFFFFF);
    matlab_coefficient_count.chunks[1] = (uint32_t) 0; // Upper 32 bits are always 0

    coder::array<double, 2U> matlab_ppg_signal = godot_signal_to_matlab_signal(preprocessed_ppg_signal);

    // Call main function
    coder::array<double, 1U> matlab_scores;
    score_ppg_signal_fourier(matlab_ppg_signal, matlab_coefficient_count, matlab_scores);

    return matlab_scores_to_godot_scores(matlab_scores);
}


// This function is a wrapper around the MATlAB autogenerated C++ code
// See README for link to the MATLAB repository
PackedFloat64Array PpgAnalyzer::calculate_pulse_scores_linear_slope(PackedFloat64Array preprocessed_ppg_signal) {
    coder::array<double, 2U> matlab_ppg_signal = godot_signal_to_matlab_signal(preprocessed_ppg_signal);

    coder::array<double, 1U> matlab_scores;
    score_ppg_signal_linear_slope(matlab_ppg_signal, matlab_scores);

    return matlab_scores_to_godot_scores(matlab_scores);
}

// This function is a wrapper around the MATlAB autogenerated C++ code
// See README for link to the MATLAB repository
PackedFloat64Array PpgAnalyzer::calculate_pulse_scores_rising_edge_area(PackedFloat64Array preprocessed_ppg_signal) {
    coder::array<double, 2U> matlab_ppg_signal = godot_signal_to_matlab_signal(preprocessed_ppg_signal);

    coder::array<double, 1U> matlab_scores;
    score_ppg_signal_rising_edge_area(matlab_ppg_signal, matlab_scores);

    return matlab_scores_to_godot_scores(matlab_scores);
}

// This function is a wrapper around the MATlAB autogenerated C++ code
// See README for link to the MATLAB repository
PackedFloat64Array PpgAnalyzer::calculate_pulse_scores_peak_detection(PackedFloat64Array preprocessed_ppg_signal) {
    coder::array<double, 2U> matlab_ppg_signal = godot_signal_to_matlab_signal(preprocessed_ppg_signal);

    coder::array<double, 1U> matlab_scores;
    score_ppg_signal_peak_detection(matlab_ppg_signal, matlab_scores);

    return matlab_scores_to_godot_scores(matlab_scores);
}