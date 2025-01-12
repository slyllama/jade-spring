shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform sampler2D noise_texture: hint_default_black;
uniform vec3 base_color: source_color;
uniform sampler2D grad_h: hint_default_white, repeat_disable;
uniform float h_position: hint_range(-1.0, 1.0) = 0.0;
uniform sampler2D grad_v: hint_default_white, repeat_disable;

void fragment() {
	ALBEDO = base_color;
	ALPHA = texture(noise_texture, UV + vec2(TIME * 0.2, 0.0)).r;
	ALPHA *= texture(grad_h, UV + vec2(h_position, 0)).r;
	ALPHA *= pow(texture(grad_h, UV).r, 2.0);
	ALPHA *= texture(grad_v, UV).r;
}