shader_type canvas_item;

uniform int palette = 0;
uniform int palette_length = 4;

ivec3 round_color(vec4 color) {
	return ivec3(round(color.rgb * 255.0));
}

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	ivec3 color = round_color(original_color);
	
	COLOR = original_color;
	for (int i = 0; i < palette_length; i++) {
		ivec3 palette_color = round_color(texture(TEXTURE, vec2(0., TEXTURE_PIXEL_SIZE.y * float(i))));
		if (palette_color == color) {
			// set color to shifted color from palette
			vec4 new_color = texture(TEXTURE, vec2(TEXTURE_PIXEL_SIZE.x * float(palette), TEXTURE_PIXEL_SIZE.y * float(i)));
			COLOR = vec4(new_color.rgb, mix(original_color.a, new_color.a, 0.0));
			break;
		}
	}
}