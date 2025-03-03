#include "../include/ppg_reader.hpp"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void PpgReader::_bind_methods() {
    ClassDB::bind_method(D_METHOD("read_ppg_from_image", "camera_frame", "bounding_box"), &PpgReader::read_ppg_from_image);
}

PpgReader::PpgReader() {

}

PpgReader::~PpgReader() {

}

int PpgReader::read_ppg_from_image(Ref<Image> camera_frame, Rect2i bounding_box) {
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