shader_type spatial;
render_mode blend_mix, unshaded;

uniform sampler2D stars_texture: filter_linear_mipmap, repeat_enable;
uniform vec3 albedo: source_color = vec3(0.5);
uniform vec3 fresnel_color: source_color = vec3(1.0);
uniform float uv_scale = 9.0;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(
		dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void fragment() {
	ALPHA = fresnel(0.5, NORMAL, VIEW) * 1.5;
	ALBEDO = texture(stars_texture, SCREEN_UV * uv_scale).rgb * albedo;
	ALBEDO += pow(fresnel(2.0, NORMAL, VIEW), 2.0) * fresnel_color;
}
