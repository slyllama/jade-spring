shader_type spatial;

uniform float uv_scale = 18.0;
uniform sampler2D grass_texture_base: source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D grass_texture_add: source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D grass_normal_texture: filter_linear_mipmap, repeat_enable;
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
	
	vec3 grass_base = texture(grass_texture_base, UV * uv_scale).rgb;
	vec3 grass_add = texture(grass_texture_add,
		rotate_uv(UV, vec2(0.5), PI / 2.0) * uv_scale * 0.5).rgb;
	vec3 grass_normal = texture(grass_normal_texture, UV * uv_scale).rgb;
	
	ALBEDO = mix(grass_base * 0.5, grass_add * 1.5, blend_noise);
	NORMAL_MAP = grass_normal;
	NORMAL_MAP_DEPTH = 1.0;
	SPECULAR = 0.2;
}

