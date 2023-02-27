shader_type canvas_item;

uniform float time = 0;
const vec4 transparent = vec4(0,0,0,0);

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	if ((1.0-UV.x) + UV.y > time*2.0) {
		COLOR = original_color;
	} else {
		COLOR = transparent;
	}
}