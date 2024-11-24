shader_type spatial;

uniform sampler2D rock_texture: source_color, filter_linear_mipmap;
uniform sampler2D normal_multires_texture: hint_normal, filter_linear_mipmap;
uniform sampler2D normal_rock_texture: hint_normal, filter_linear_mipmap;
uniform sampler2D lighten_texture: source_color, filter_linear_mipmap, hint_default_black;

uniform sampler2D overlay_texture: source_color, filter_linear_mipmap, hint_default_black;
uniform sampler2D overlay_mask: source_color, filter_linear_mipmap, hint_default_black; // uses green
uniform vec3 overlay_color: source_color;
uniform float overlay_exponent = 1.0;
uniform float overlay_uv_scale = 1.0;
uniform float uv_scale = 2.0;
uniform float darken = 1.0;

void fragment() {
	ALBEDO = texture(rock_texture, UV * uv_scale).rgb * 0.55;
	ALBEDO *= darken;
	ALBEDO *= 1.0 + pow(texture(lighten_texture, UV).rgb, vec3(1.5)) * 3.0;
	ALBEDO = mix(ALBEDO, texture(overlay_texture, UV * overlay_uv_scale).rgb
		* overlay_color, pow(texture(overlay_mask, UV).g, overlay_exponent));
	NORMAL_MAP = mix(texture(normal_multires_texture, UV).rgb, texture(normal_rock_texture, UV).rgb, 0.5);
	NORMAL_MAP_DEPTH = 4.0;
	SPECULAR = 0.0;
}
