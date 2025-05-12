shader_type spatial;

uniform sampler2D cloth_diff: hint_default_black;
uniform sampler2D mask: hint_default_black;
uniform sampler2D stain_mask: hint_default_black;
uniform float stain_strength: hint_range(0.0, 1.0) = 0.7;
uniform sampler2D cloth_norm: hint_normal;
uniform vec3 albedo: source_color = vec3(0.5);
uniform vec3 stain_albedo: source_color;
uniform float uv_scale = 2.0;

void fragment() {
	ALBEDO = texture(cloth_diff, UV * uv_scale).rgb * albedo;
	ALBEDO = mix(ALBEDO, stain_albedo, texture(stain_mask, UV).r * stain_strength);
	NORMAL_MAP = texture(cloth_norm, UV * uv_scale).rgb;
	NORMAL_MAP_DEPTH = 1.0;
	ALPHA = texture(mask, UV).r;
	SPECULAR = 0.0;
}
