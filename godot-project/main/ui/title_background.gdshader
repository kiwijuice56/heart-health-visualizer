shader_type canvas_item;

uniform sampler2D gradient: source_color;
uniform sampler2D fractal_gradient: source_color;
uniform float speed = 1.0;
uniform float fractal_mix = 0.5;

// http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns/
float field(in vec3 p, float spice) {
	float strength = 7.0;
	float accum = 0.;
	float prev = 0.;
	float tw = 0.;
	for (int i = 0; i < 16; ++i) {
		float mag = dot(p, p);
		p = abs(p) / mag + vec3(-.5, -.4, -1.5 + 0.02 * cos(spice));
		float w = exp(-float(i) / 7.);
		accum += w * exp(-strength * pow(abs(mag - prev), 2.3 + 0.2 * sin(spice)));
		tw += w;
		prev = mag;
	}
	return max(0., 5. * accum / tw - .7);
}

void fragment() {
	float aspect_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 base_uv = SCREEN_UV;
	vec2 uv = (base_uv + 0.2 * vec2(sin(speed * TIME), cos(speed * TIME)));
	uv.y *= aspect_ratio;
	float fractal = field(vec3(uv, sin(0.1 * speed * TIME)), speed * TIME);
	COLOR.rgb = texture(gradient, UV).rgb * (1.0 - fractal_mix) + (1.0 - UV.y) * texture(fractal_gradient, UV).rgb * fractal * fractal_mix;
}