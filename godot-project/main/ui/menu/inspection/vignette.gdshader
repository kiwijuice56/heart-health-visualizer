shader_type canvas_item;

uniform float alpha = 0.5;
uniform float begin = 0.9;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.a = alpha * (clamp(UV.y, begin, 1.0) - begin) / (1.0 - begin);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
