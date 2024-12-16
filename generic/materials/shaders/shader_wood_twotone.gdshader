shader_type spatial;
// Red - desaturate and lighten
// Blue - darken

uniform sampler2D wood_texture: hint_default_black;
uniform sampler2D wood_normal_texture: hint_normal;
uniform sampler2D stain_mask_texture: hint_default_black, filter_linear_mipmap;
uniform float base_brightness = 1.0;
uniform float uv_scale = 1.0;
uniform float saturation_value = 1.2;

vec3 saturation(vec3 input, float value) {
	return(mix(vec3(dot(input.rgb, vec3(0.299, 0.587, 0.114))), input.rgb, value));
}

void fragment() {
	vec3 albedo = texture(wood_texture, UV * uv_scale).rgb * base_brightness;
	vec3 stain_mask = texture(stain_mask_texture, UV).rgb;
	
	albedo = mix(albedo, saturation(albedo * vec3(2.0), 0.5), stain_mask.r);
	albedo = mix(albedo, albedo * 0.35, stain_mask.b);
	albedo = saturation(albedo, saturation_value);
	
	NORMAL_MAP = texture(wood_normal_texture, UV * uv_scale).rgb;
	SPECULAR = 0.0;
	ALBEDO = albedo;
}
