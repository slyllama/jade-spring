shader_type spatial;
render_mode blend_add, alpha_to_coverage, unshaded, cull_disabled;

uniform sampler2D alpha_mask: hint_default_white, filter_linear_mipmap;
uniform vec3 albedo: source_color = vec3(1.0, 1.0, 0.0);

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal),
		normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	ALBEDO = albedo;
	ALPHA = clamp(fresnel(1.5, NORMAL, VIEW) + 0.3, 0.0, 1.0);
	ALPHA *= texture(alpha_mask, UV).a;
}
