shader_type canvas_item;

uniform float time = 0;
uniform int animation = 1;
uniform float border_pixels = 4;
uniform vec4 border_color = vec4(0,0,0,1);
const vec4 transparent = vec4(0,0,0,0);
const int anim_count = 3;
	
float diagonal_swipe(float border_size, vec2 uv) {
	return ((1.0-uv.x) + uv.y)/2.0;
}

float circle_swipe(float border_size, vec2 uv) {
	return distance(uv, vec2(0.5, 0.5));
}

float quad_swipe(float border_size, vec2 uv) {
	return min(abs(uv.x-0.5)*2.0, abs(uv.y-0.5)*2.0);
}

vec2 quad_offset(vec2 uv) {
	vec2 off = vec2(
		mix(time*.5, -time*.5, ceil(uv.x-0.5)),
		mix(time*.5, -time*.5, ceil(uv.y-0.5))
	);
	return off;
}

float cond(float v) {
	return ceil(v);
}

void fragment() {
	vec2 offsets[3] = vec2[](
		vec2(0,0),
		vec2(0,0),
		quad_offset(UV)
	);
	vec4 original_color = texture(TEXTURE, UV+offsets[animation]);
	float border_size = TEXTURE_PIXEL_SIZE.x*border_pixels;
	float anims[3] = float[](
		diagonal_swipe(border_size, UV),
		circle_swipe(border_size, UV),
		quad_swipe(border_size, UV)
	);
	float d = anims[animation];
	vec4 on_color = mix(border_color, original_color, cond(d - time));
	COLOR = mix(transparent, on_color, cond(d + border_size - time));
}