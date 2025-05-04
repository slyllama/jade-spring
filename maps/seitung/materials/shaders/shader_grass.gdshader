shader_type spatial;

uniform float uv_scale = 18.0;
uniform sampler2D grass_texture_base: source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D grass_texture_add: source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D grass_normal_texture: filter_linear_mipmap, repeat_enable, hint_normal;
uniform sampler2D blend_noise_texture: filter_linear_mipmap, repeat_enable, hint_default_black;

uniform sampler2D dirt_texture: source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D dirt_mask_texture: filter_linear_mipmap, hint_default_black;
uniform sampler2D rock_texture: source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D rock_normal_texture: filter_linear_mipmap, repeat_enable, hint_normal;

uniform float grass_base_multiplier = 0.45;
uniform float normal_strength = 1.0;
uniform float grass_add_multiplier = 0.7;
uniform float dirt_uv_multiplier = 1.55;

uniform sampler2D sand_mask: hint_default_black;
uniform sampler2D sand_diff: filter_linear_mipmap;
uniform float sand_uv_scale = 1.0;

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
	float dirt_blend = texture(dirt_mask_texture, UV).b;
	float light_blend = texture(dirt_mask_texture, UV).r;
	float rock_blend = texture(dirt_mask_texture, UV).g;

	vec3 grass_base = texture(grass_texture_base, UV * uv_scale).rgb;
	vec3 grass_add = texture(grass_texture_add, rotate_uv(UV, vec2(0.5), PI / 2.0) * uv_scale * 0.5).rgb;
	vec3 grass_normal = texture(grass_normal_texture, UV * uv_scale).rgb;
	vec3 rock_normal = texture(rock_texture, UV * 11.0).rgb;

	vec3 dirt = texture(dirt_texture, UV * uv_scale * dirt_uv_multiplier).rgb;

	ALBEDO = mix(grass_base * grass_base_multiplier, grass_add * grass_add_multiplier, blend_noise);
	ALBEDO = mix(ALBEDO, dirt, dirt_blend);
	ALBEDO = mix(ALBEDO, texture(rock_texture, UV * 11.0).rgb * 1.63, rock_blend * 1.45);
	ALBEDO = mix(ALBEDO, texture(sand_diff, UV * sand_uv_scale).rgb * 0.95, texture(sand_mask, UV).r);
	ALBEDO *= (1.0 + light_blend);

	NORMAL_MAP = grass_normal;
	NORMAL_MAP = mix(NORMAL_MAP, rock_normal, rock_blend);

	NORMAL_MAP_DEPTH = normal_strength;
	SPECULAR = 0.0;
}
