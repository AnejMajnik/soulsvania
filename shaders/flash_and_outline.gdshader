shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 pixel_offset = TEXTURE_PIXEL_SIZE;
    
    // Sample the base texture and neighbors
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 right_color = texture(TEXTURE, UV + vec2(pixel_offset.x, 0.0));
    vec4 left_color  = texture(TEXTURE, UV + vec2(-pixel_offset.x, 0.0));
    vec4 up_color    = texture(TEXTURE, UV + vec2(0.0, -pixel_offset.y));
    vec4 down_color  = texture(TEXTURE, UV + vec2(0.0, pixel_offset.y));
    
    // Apply flash effect
    if (tex_color.a > 0.3) {
        tex_color.rgb = mix(tex_color.rgb, flash_color.rgb, flash_amount);
    }
    
    // Apply outline
    if (tex_color.a < 0.5 && (left_color.a > 0.5 || right_color.a > 0.5 || up_color.a > 0.5 || down_color.a > 0.5)) {
        COLOR = outline_color;
    } else {
        COLOR = tex_color;
    }
}