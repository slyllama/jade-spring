shader_type canvas_item;

uniform float lod: hint_range(0.0, 5) = 0.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D mask: hint_default_black;
uniform sampler2D mask2: hint_default_black;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
	COLOR = color;
	COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), 0.5);
	COLOR *= texture(mask, UV).r;
	COLOR *= texture(mask2, UV).r;
	
}
