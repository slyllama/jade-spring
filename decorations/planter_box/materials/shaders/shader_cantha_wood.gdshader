shader_type spatial;

uniform sampler2D wood_texture: hint_default_black;
uniform sampler2D wood_normal_texture: hint_normal;
uniform sampler2D data_mask: hint_default_black;
uniform sampler2D ornament_texture: hint_default_black;
uniform vec3 albedo: source_color;
uniform vec3 ornament_albedo: source_color;
uniform float ornament_uv_scale: hint_range(0.1, 10.0) = 2.0;
uniform float wood_uv_scale: hint_range(0.1, 10.0) = 2.0;

vec3 color_dodge(vec3 base, vec3 blend){
	return base / (1.0 - blend);
}

void fragment() {
	ALBEDO = texture(wood_texture, UV * wood_uv_scale).rgb;
	ALBEDO *= albedo;
	ALBEDO = mix(ALBEDO, texture(ornament_texture, UV * wood_uv_scale).rgb * ornament_albedo, texture(data_mask, UV).g);
	ALBEDO = mix(ALBEDO, color_dodge(ALBEDO, vec3(0.8)), pow(texture(data_mask, UV).r, 2.0));
	NORMAL_MAP = texture(wood_normal_texture, UV * wood_uv_scale).rgb;
	SPECULAR = 0.0;
}
