shader_type spatial;

uniform sampler2D brick_texture: hint_default_black;
uniform sampler2D plaster_texture: hint_default_black;
uniform sampler2D brick_norm_texture: hint_normal;
uniform sampler2D plaster_mask_texture: hint_default_black;
uniform float uv_scale: hint_range(0.0, 50.0) = 3.0;
uniform float normal_strength = 1.0;
uniform vec3 albedo: source_color = vec3(1.0);

void fragment() {
	float plaster_mask = texture(plaster_mask_texture, UV).r;
	vec3 combine = mix(texture(brick_texture, UV * uv_scale).rgb, texture(plaster_texture, UV * uv_scale).rgb, plaster_mask);
	ALBEDO = combine * albedo;
	NORMAL_MAP = texture(brick_norm_texture, UV * uv_scale).rgb;
	NORMAL_MAP_DEPTH = (1.0 - plaster_mask) * normal_strength;
	SPECULAR = 0.2;
}
