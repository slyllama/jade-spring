shader_type spatial;
render_mode specular_disabled;

uniform sampler2D albedo_texture: source_color, filter_linear_mipmap;
uniform sampler2D normal_texture: hint_normal;
uniform float uv_scale = 1.0;
uniform float normal_strength = 1.0;
uniform vec3 albedo_color: source_color = vec3(1.0);

void fragment() {
	ALBEDO = texture(albedo_texture, UV * uv_scale).rgb * albedo_color;
	NORMAL_MAP = texture(normal_texture, UV * uv_scale).rgb;
	NORMAL_MAP_DEPTH = normal_strength;
	
	float fade_distance = length(VERTEX);
	const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	float fade = clamp(smoothstep(1.0, 1.5, fade_distance), 0.0, 1.0);
	if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
		discard;
	}
}
