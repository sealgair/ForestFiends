shader_type canvas_item;

uniform float time = 0;
uniform float border_size = 4;
uniform vec4 border_color = vec4(0,0,0,1);
const vec4 transparent = vec4(0,0,0,0);

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	float bs = TEXTURE_PIXEL_SIZE.x*border_size;
	float d = ((1.0-UV.x) + UV.y)/2.0 + bs;
	if (d > time) {
		if (d-bs < time) {
			COLOR = border_color;
		} else {
			COLOR = original_color;
		}
	} else {
		COLOR = transparent;
	}
}