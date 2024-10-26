shader_type spatial;

uniform sampler2D wood_texture: source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D wood_normal_texture: filter_linear_mipmap, hint_normal, repeat_enable;
uniform sampler2D occlusion_mask: filter_linear_mipmap, hint_default_black;
uniform float occlusion_intensity = 1.0;
uniform float uv_scale = 1.0;
uniform float saturation = 1.0;
uniform float multiplier = 1.0;

void fragment() {
	NORMAL_MAP = texture(wood_normal_texture, UV * uv_scale).rgb;
	ALBEDO = texture(wood_texture, UV * uv_scale).rgb;
	ALBEDO += texture(occlusion_mask, UV).rgb * occlusion_intensity;
	ALBEDO = mix(vec3(dot(ALBEDO.rgb, vec3(0.299, 0.587, 0.114))), ALBEDO.rgb, saturation);
	ALBEDO *= multiplier;
}

