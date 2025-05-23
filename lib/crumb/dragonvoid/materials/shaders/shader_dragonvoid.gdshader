shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded, shadows_disabled, ambient_light_disabled, fog_disabled;

uniform sampler2D v_gradient_texture: hint_default_black;
uniform sampler2D h_gradient_texture: hint_default_black;
uniform sampler2D smoke_texture: hint_default_black;
uniform sampler2D albedo_texture: hint_default_black;
uniform float speed = 0.21;
uniform float exponent = 1.0;

vec2 make_river_uv(vec2 uv, float river_speed) {
	return(uv * vec2(4.0, 1.0) * 0.35 + TIME * vec2(river_speed, 0.0));
}

void fragment() {
	ALBEDO = texture(albedo_texture, make_river_uv(UV, speed) * 0.8).rgb;
	ALPHA *= texture(v_gradient_texture, UV).r;
	ALPHA *= texture(h_gradient_texture, UV).r;
	ALPHA *= texture(smoke_texture, make_river_uv(UV, speed)).r;
	
	{
		float fade_distance = length(VERTEX);
		const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
		float fade = clamp(smoothstep(20.0, 18.0, fade_distance), 0.0, 1.0);
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
	}
}
