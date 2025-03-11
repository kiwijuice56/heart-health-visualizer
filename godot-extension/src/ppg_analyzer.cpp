#include "../include/ppg_analyzer.hpp"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void PpgAnalyzer::_bind_methods() {
    ClassDB::bind_method(D_METHOD("read_ppg_from_image", "camera_frame", "bounding_box"), &PpgAnalyzer::read_ppg_from_image);
    ClassDB::bind_method(D_METHOD("smoothed_ppg_signal", "ppg_values", "window_size"), &PpgAnalyzer::smoothed_ppg_signal);
    ClassDB::bind_method(D_METHOD("calculate_heart_rate", "ppg_values", "sampling_frequency"), &PpgAnalyzer::calculate_heart_rate);
    ClassDB::bind_method(D_METHOD("calculate_heart_rate_variability", "ppg_values", "sampling_frequency"), &PpgAnalyzer::calculate_heart_rate_variability);
}

PpgAnalyzer::PpgAnalyzer() {

}

PpgAnalyzer::~PpgAnalyzer() {

}

int PpgAnalyzer::read_ppg_from_image(Ref<Image> camera_frame, Rect2i bounding_box) {
    const int start_y = bounding_box.get_position().y;
    const int end_y = start_y + bounding_box.get_size().y;

    const int start_x = bounding_box.get_position().x;
    const int end_x = start_x + bounding_box.get_size().x;

    int ppg_point = 0;

    for (int y = start_y; y < end_y; y++) {
        for (int x = start_x; x < end_x; x++) {
            Color pixel_color = camera_frame->get_pixel(x, y);

            ppg_point += pixel_color.get_r8();
        }
    }

    return ppg_point;
}

PackedInt32Array PpgAnalyzer::smoothed_ppg_signal(PackedInt32Array ppg_values, int window_size) {
    PackedInt32Array smoothed_signal;
    smoothed_signal.resize(ppg_values.size());

    int64_t window_sum = 0;
    for (int i = 0; i < ppg_values.size(); i++) {
        window_sum += ppg_values[i];

        smoothed_signal[i] = (int) (window_sum / window_size);

        if (i >= window_size) {
            window_sum -= ppg_values[i - window_size];
        }
    }

    return smoothed_signal;
}

float PpgAnalyzer::calculate_heart_rate(PackedInt32Array ppg_values, float sampling_frequency) {
    return 0.0;
}

float PpgAnalyzer::calculate_heart_rate_variability(PackedInt32Array ppg_values, float sampling_frequency) {
    return 0.0;
}