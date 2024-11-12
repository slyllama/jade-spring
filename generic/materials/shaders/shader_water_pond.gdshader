shader_type spatial;

uniform vec4 primary_color: source_color;
uniform float roughness = 0.2;
uniform sampler2D normal_a: hint_normal;
uniform sampler2D normal_b: hint_normal;
uniform sampler2D light_foam: filter_linear_mipmap, repeat_enable;
uniform vec2 uv_scale = vec2(1.0);
uniform float alpha = 1.0;
uniform float speed_scale = 1.0;
uniform float normal_strength = 1.0;
uniform float foam_exponent = 3.0;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(
		dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	vec2 uv = UV * uv_scale;
	vec3 normal_map = texture(normal_a, uv + TIME * 0.01 * speed_scale).rgb * 0.4;
	normal_map += texture(normal_b, uv - TIME * 0.005 * speed_scale).rgb * 0.7;
	
	ALBEDO = primary_color.rgb * pow(texture(light_foam, uv - TIME * 0.012 * speed_scale).rgb, vec3(foam_exponent)) + 0.5 * vec3(fresnel(2.0, NORMAL, VIEW));
	NORMAL_MAP = normal_map;
	NORMAL_MAP_DEPTH = normal_strength;
	ROUGHNESS = roughness;
	ALPHA = alpha;
}
