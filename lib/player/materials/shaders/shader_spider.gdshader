shader_type spatial;
render_mode unshaded;

uniform vec3 color: source_color;
uniform vec3 color_2: source_color;
uniform float fresnel_amount = 1.0;
uniform float fresnel_exponent = 1.0;
uniform float alpha_lower_clamp = 0.5;
uniform float alpha = 1.0;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal),
		normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	float fresnel_calc = pow(fresnel(fresnel_amount, NORMAL, VIEW), fresnel_exponent);
	ALBEDO = mix(color, color_2, fresnel(fresnel_amount / 1.5, NORMAL, VIEW));
	ALPHA = clamp(fresnel_calc, alpha_lower_clamp, 1.0);
	ALPHA *= alpha;
}
