shader_type spatial;
render_mode blend_mix, ambient_light_disabled, fog_disabled, unshaded,
shadows_disabled, cull_disabled;
// Visual area

uniform sampler2D mask_texture: source_color;
uniform sampler2D vertical_mask: hint_default_white;
uniform float uv_scale = 1.0;
uniform float exponent = 2.0;
uniform float time_scale = 0.07;

void fragment() {
	ALPHA = texture(mask_texture, UV * vec2(uv_scale) + vec2(0, TIME * time_scale)).r;
	ALPHA = pow(ALPHA, exponent);
	//ALPHA += 0.01;
	ALPHA *= texture(vertical_mask, UV).r;
}
