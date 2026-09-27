shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2 pixel_offset = TEXTURE_PIXEL_SIZE;
	
	vec4 right_color = texture(TEXTURE, UV + vec2(pixel_offset.x, 0.0));
	vec4 left_color  = texture(TEXTURE, UV + vec2(-pixel_offset.x, 0.0));
    vec4 up_color    = texture(TEXTURE, UV + vec2(0.0, -pixel_offset.y));
    vec4 down_color  = texture(TEXTURE, UV + vec2(0.0, pixel_offset.y));
	
	if (COLOR.a < 0.5 && (left_color.a > 0.5 || right_color.a > 0.5 || up_color.a > 0.5 || down_color.a > 0.5)) {
		COLOR = outline_color;
	}
}
