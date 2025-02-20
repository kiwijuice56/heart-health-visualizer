#include "../include/fractal_flame_renderer.hpp"

#include <godot_cpp/core/class_db.hpp>

# define PI 3.14159265358979323846

using namespace godot;

void FractalFlameRenderer::_bind_methods() {
    ClassDB::bind_method(D_METHOD("render", "image_size", "initial_radius", "sample_count", "iteration_count", "initial_iteration_ignore_count"), &FractalFlameRenderer::render);
}

FractalFlameRenderer::FractalFlameRenderer() {

}

FractalFlameRenderer::~FractalFlameRenderer() {

}

Ref<ImageTexture> FractalFlameRenderer::render(Vector2i image_size, double initial_radius, int sample_count, int iteration_count, int initial_iteration_ignore_count) {
    // Initialize image data
    const Ref<Image> render_image = Image::create_empty(image_size.x, image_size.y, false, Image::FORMAT_RGBA8);
    const Vector2i image_offset = image_size / 2;

    // Initialize histograms
    const int array_size = image_size.x * image_size.y;
    PackedInt64Array histogram_frequency;
    PackedColorArray histogram_color;
    histogram_frequency.resize(array_size);
    histogram_color.resize(array_size);

    int max_frequency = 0;

    // Sample random points and iterate over fractal functions
    for (int i = 0; i < sample_count; i++) {
        Vector2 point = Vector2(initial_radius, 0).rotated(UtilityFunctions::randf() * PI);
        Color point_color = Color(UtilityFunctions::randf(), UtilityFunctions::randf(), UtilityFunctions::randf());

        for (int j = 0; j < iteration_count; j++) {
            const double point_distance = point.length();

            // Iterate over random functions
            // TODO: modularize this

            if (UtilityFunctions::randf() < 0.5) {
                // Cosine function

                point = point_distance * Vector2(
                    UtilityFunctions::cos(2 * PI * point.x / image_size.x),
                    UtilityFunctions::cos(2 * PI * point.y / image_size.y)
                );

                point_color = (point_color + Color(0.4, 1.0, 0.4)) / 2;
            } else {
                // Linear function

                point *= Vector2(1.15, 0.95);

                point_color = (point_color + Color(0.2, 0.4, 1.0)) / 2;
            }


            // Ignoring initial iterations reduces noise around the middle
            if (j < initial_iteration_ignore_count) {
                continue;
            }

            const Vector2i image_coordinate = Vector2i(point) + image_offset;
            if (image_coordinate.x < 0 || image_coordinate.x >= image_size.x || image_coordinate.y < 0 || image_coordinate.y >= image_size.y) {
                continue;
            }

            const int array_index = image_coordinate.x + image_coordinate.y * image_size.x;

            // Update frequency
            histogram_frequency[array_index]++;
            max_frequency = UtilityFunctions::max(histogram_frequency[array_index], max_frequency);

            // Blend color at this pixel
            histogram_color[array_index] = (histogram_color[array_index] + point_color) / 2;
        }
    }

    const double log_max_frequency = UtilityFunctions::log(max_frequency);

    for (int y = 0; y < image_size.y; y++) {
        for (int x = 0; x < image_size.x; x++) {
            const int array_index = x + y * image_size.x;
            const double alpha = UtilityFunctions::log(histogram_frequency[array_index]) / log_max_frequency;
            const Color pixel_color = Color(histogram_color[array_index], alpha);

            render_image->set_pixel(x, y, pixel_color);
        }
    }

    return ImageTexture::create_from_image(render_image);
}