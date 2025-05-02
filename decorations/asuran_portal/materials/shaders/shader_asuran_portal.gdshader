shader_type spatial;
render_mode cull_disabled;

uniform sampler2D noise_edge_texture: hint_default_black;
uniform vec3 albedo: source_color = vec3(0.5);

uniform vec3 color_a: source_color = vec3(0.5);
uniform vec3 color_b: source_color = vec3(0.5);

float circle(vec2 position, float radius, float feather) {
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}

void fragment() {
	vec2 og_uv = UV;
	og_uv -= vec2(0.5);

	float uv_x = sqrt(dot(og_uv, og_uv)) * 2.0;
	float uv_y = (atan(og_uv.x, og_uv.y) / -3.14) * 0.5 + 0.5;
	float wobble = texture(noise_edge_texture, UV + TIME * 0.1).r;
	
	ALBEDO = mix(color_a, color_b, wobble);
	EMISSION = ALBEDO * 1.6;
	
	ALPHA = texture(noise_edge_texture, vec2(
		uv_x + TIME * 0.35 + wobble * 0.05, uv_y - wobble * 0.1
	)).r * albedo.r;
	ALPHA = pow(ALPHA, 1.5) * 5.0;
	ALPHA = min(ALPHA, 1.0 - circle(UV, 0.4, 0.05 * wobble));
	ALPHA = min(ALPHA, circle(UV, 0.2, 0.5 * wobble));
	
	ALPHA = clamp(ALPHA, 0.0, 1.0);
}

