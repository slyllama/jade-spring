shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform sampler2D noise_texture: hint_default_black;
uniform sampler2D grad_h: hint_default_white, repeat_disable;
uniform vec3 base_color: source_color;
uniform float h_position: hint_range(-0.5, 0.5) = 0.0;

void fragment() {
	ALBEDO = base_color;
	ALPHA = texture(noise_texture, UV).r;
	ALPHA *= texture(grad_h, UV + vec2(h_position, 0)).r;
}