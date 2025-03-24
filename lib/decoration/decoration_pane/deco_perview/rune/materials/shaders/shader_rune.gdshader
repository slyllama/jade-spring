shader_type spatial;
render_mode unshaded, cull_disabled, ambient_light_disabled, fog_disabled, blend_mix, shadows_disabled, specular_disabled;

uniform sampler2D rune: hint_default_black, repeat_disable;
uniform sampler2D wobble_tex: hint_default_black, filter_linear_mipmap, repeat_enable;

void fragment() {
	float wobble2 = texture(wobble_tex, UV * 0.3 + TIME * 0.1).r * 0.5;
	vec2 uv2 = UV * 0.6 + vec2(0.18, 0.18) + wobble2 * 0.04;
	ALPHA = texture(rune, uv2).a * 0.2;
}
