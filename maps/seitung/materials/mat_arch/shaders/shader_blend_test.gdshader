/*
	Mesh Blending with Alpha Shader by Firerabbit
	
	MIT License
*/
shader_type spatial;
render_mode depth_draw_always;

uniform float proximity_fade_distance : hint_range(0.0, 1.0) = 0.3;
uniform float falloff : hint_range(0.001, 5.0) = 1.0;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;
uniform vec4 color : source_color = vec4(1.0);
uniform sampler2D albedo : hint_default_black, filter_linear_mipmap, repeat_enable;



float saturate(float val) {
	return clamp(val, 0.0, 1.0);
}

void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(UV, depth, 1.0);
	world_pos.xyz /= world_pos.w;
	
	ALPHA *= saturate(1.0 - smoothstep(world_pos.z + proximity_fade_distance, world_pos.z, VERTEX.z));
	ALPHA = pow(ALPHA, falloff);
	ALBEDO = color.rgb * texture(albedo, UV).rgb;
}