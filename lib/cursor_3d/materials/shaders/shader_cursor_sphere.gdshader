shader_type spatial;
render_mode blend_mix, unshaded, shadows_disabled, ambient_light_disabled,
	fog_disabled, alpha_to_coverage, cull_disabled;

uniform float fresnel_amount = 4.3;
uniform vec4 albedo: source_color;
uniform sampler2D gradient_texture: hint_default_white;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(
		dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	ALBEDO = albedo.rgb;
	ALPHA = fresnel(fresnel_amount, NORMAL, VIEW);
	ALPHA += texture(gradient_texture, UV).r;
}
