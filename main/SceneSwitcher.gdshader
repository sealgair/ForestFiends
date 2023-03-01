shader_type canvas_item;

uniform float time = 0;
uniform int animation = 1;
uniform vec2 direction = vec2(1,1);
uniform float border_pixels = 4;
uniform vec4 border_color = vec4(0,0,0,1);
const vec4 transparent = vec4(0,0,0,0);
const int anim_count = 3;
	
float dir_flip(float v, float s) {
	return mix(1.0-v, v, ceil(s*.75));
}

float diagonal_display(vec2 uv) {
	// TODO: flash of white in opposite corner at very start
	float x = dir_flip(uv.x, direction.x);
	float y = dir_flip(uv.y, -direction.y);
	return (x+y)*.5;
}

float circle_display(vec2 uv) {
	return dir_flip(distance(uv, vec2(0.5, 0.5)), -direction.y);
}

float quad_display(vec2 uv) {
	return min(abs(uv.x-0.5)*2.0, abs(uv.y-0.5)*2.0);
}

vec2 quad_offset(vec2 uv) {
	vec2 off = vec2(
		mix(time*.5, -time*.5, ceil(uv.x-0.5)),
		mix(time*.5, -time*.5, ceil(uv.y-0.5))
	);
	return off;
}

float fall_display(vec2 uv) {
	return dir_flip(uv.y, -direction.y);
}

vec2 fall_offset(vec2 uv) {
	return vec2(0, dir_flip(time, direction.y));
}

float swipe_display(vec2 uv) {
	return dir_flip(uv.x, direction.x);
}

vec2 swipe_offset(vec2 uv) {
	return vec2(dir_flip(time, -direction.x), 0);
}

float cond(float v) {
	return ceil(v);
}

void fragment() {
	vec2 offsets[5] = vec2[](
		vec2(0,0),
		vec2(0,0),
		quad_offset(UV),
		fall_offset(UV),
		swipe_offset(UV)
	);
	vec4 original_color = texture(TEXTURE, UV+offsets[animation]);
	float border_size = TEXTURE_PIXEL_SIZE.x*border_pixels;
	float anims[5] = float[](
		diagonal_display(UV),
		circle_display(UV),
		quad_display(UV),
		fall_display(UV),
		swipe_display(UV)
	);
	float d = anims[animation];
	vec4 on_color = mix(border_color, original_color, cond(d - time));
	COLOR = mix(transparent, on_color, cond(d + border_size - time));
}