shader_type spatial;
render_mode unshaded, ambient_light_disabled, fog_disabled, blend_add, shadows_disabled;

uniform sampler2D rune: hint_default_black, filter_linear_mipmap, repeat_disable;
uniform sampler2D wobble_tex: hint_default_black, filter_linear_mipmap, repeat_enable;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap, repeat_disable;

void fragment() {
	float wobble = texture(wobble_tex, UV * 0.5 + TIME * 0.1).r;
	vec2 uv = UV + wobble * 0.04;
	EMISSION = vec3(1.0, 1.0, 1.0);
	ALPHA = texture(rune, uv).a;
}
