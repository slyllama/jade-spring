shader_type spatial;

uniform float uv_scale = 18.0;
uniform sampler2D grass_texture: source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D blend_noise_texture: filter_linear_mipmap, repeat_enable, hint_default_black;

vec2 rotate_uv(vec2 uv, vec2 pivot, float rotation) {
	float cosa = cos(rotation);
	float sina = sin(rotation);
	uv -= pivot;
	return vec2(
		cosa * uv.x - sina * uv.y,
		cosa * uv.y + sina * uv.x 
	) + pivot;
}

void fragment() {
	float blend_noise = texture(blend_noise_texture, UV).r;
	vec3 grass_1 = texture(grass_texture, UV * uv_scale).rgb;
	vec3 grass_2 = texture(grass_texture, rotate_uv(UV, vec2(0.5), PI / 2.0) * uv_scale * 0.75).rgb;
	
	ALBEDO = mix(grass_1, grass_2, blend_noise);
	SPECULAR = 0.0;
}

