shader_type spatial;

uniform vec4 primary_color: source_color;
uniform float roughness = 0.2;
uniform sampler2D normal_a: hint_normal;
uniform sampler2D normal_b: hint_normal;
uniform sampler2D light_foam: filter_linear_mipmap, repeat_enable;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(
		dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	
	vec3 normal_map = texture(normal_a, UV + TIME * 0.01).rgb * 0.4;
	normal_map += texture(normal_b, UV - TIME * 0.005).rgb * 0.7;
	
	ALBEDO = primary_color.rgb * pow(texture(light_foam, UV - TIME * 0.012).rgb, vec3(3.0)) + 0.5 * vec3(fresnel(2.0, NORMAL, VIEW));
	NORMAL_MAP = normal_map;
	ROUGHNESS = roughness;
}

