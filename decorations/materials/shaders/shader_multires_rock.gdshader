shader_type spatial;

uniform sampler2D rock_texture: source_color, filter_linear_mipmap;
uniform sampler2D normal_multires_texture: hint_normal, filter_linear_mipmap;
uniform sampler2D normal_rock_texture: hint_normal, filter_linear_mipmap;
uniform sampler2D lighten_texture: source_color, filter_linear_mipmap, hint_default_black;
uniform float uv_scale = 2.0;

void fragment() {
	ALBEDO = texture(rock_texture, UV * uv_scale).rgb * 0.55;
	ALBEDO *= 1.0 + pow(texture(lighten_texture, UV).rgb, vec3(1.5)) * 3.0;
	NORMAL_MAP = mix(texture(normal_multires_texture, UV).rgb, texture(normal_rock_texture, UV).rgb, 0.5);
	NORMAL_MAP_DEPTH = 4.0;
	SPECULAR = 0.0;
}
