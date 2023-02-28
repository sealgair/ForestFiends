shader_type canvas_item;

uniform float time = 0;
uniform int animation = 1;
uniform float border_pixels = 4;
uniform vec4 border_color = vec4(0,0,0,1);
const vec4 transparent = vec4(0,0,0,0);

float diagonal_swipe(vec4 original_color, float border_size, vec2 uv) {
	return ((1.0-uv.x) + uv.y)/2.0;
}

float circle_swipe(vec4 original_color, float border_size, vec2 uv) {
	return distance(uv, vec2(0.5, 0.5));
}

float cond(float v) {
	return ceil(v);
}

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	float border_size = TEXTURE_PIXEL_SIZE.x*border_pixels;
	float anims[2] = float[](
		diagonal_swipe(original_color, border_size, UV),
		circle_swipe(original_color, border_size, UV)
	);
	float d = anims[animation];
	vec4 on_color = mix(border_color, original_color, cond(d - time));
	COLOR = mix(transparent, on_color, cond(d + border_size - time));
}