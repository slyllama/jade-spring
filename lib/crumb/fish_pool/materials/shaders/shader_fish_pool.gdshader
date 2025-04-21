shader_type spatial;
render_mode specular_disabled, blend_mix, shadows_disabled;

uniform sampler2D albedo_texture: hint_default_black, repeat_disable;
uniform sampler2D wobble_texture: hint_default_black;
uniform vec3 albedo: source_color;

void fragment() {
	vec2 og_uv = UV;
	og_uv -= vec2(0.5);
	
	float uv_x = sqrt(dot(og_uv, og_uv)) * 2.0;
	float uv_y = (atan(og_uv.x, og_uv.y) / -3.14) * 0.5 + 0.5;
	
	vec2 wobble_uv = texture(
		wobble_texture, (vec2(uv_x, uv_y) + vec2(TIME * 0.05))).rg;
	vec4 ripple = texture(albedo_texture, UV + wobble_uv * 0.024);
	
	
	ALBEDO = ripple.rgb * albedo;
	ALPHA = ripple.a;
	ALPHA *= 0.9;
	SPECULAR = 0.0;
	
	{
		float fade_distance = length(VERTEX);
		const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
		float fade = clamp(smoothstep(11.0, 10.0, fade_distance), 0.0, 1.0);
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
	}
}
