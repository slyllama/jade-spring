shader_type spatial;
render_mode blend_mix;

uniform vec4 base_color: source_color;
uniform sampler2D holo_texture: repeat_enable, hint_default_white;
uniform float holo_exponent = 2.0;
uniform float uv_scale = 200.0;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(
		dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	EMISSION = base_color.rgb * 10.0;
	ALBEDO = base_color.rgb;
	ALPHA = pow(fresnel(2.0, NORMAL, VIEW), holo_exponent);
	ALPHA *= texture(holo_texture, SCREEN_UV * uv_scale).r;
}
