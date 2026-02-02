shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, ambient_light_disabled, shadows_disabled;

uniform sampler2D mask: hint_default_white;
uniform sampler2D noise_texture: hint_default_white;
uniform float noise_scale = 0.5;
uniform float alpha = 0.7;

void fragment() {
	// Called for every vertex the material is visible on.
	ALPHA *= texture(noise_texture, UV * noise_scale + TIME * vec2(-0.01, -0.02)).r;
	ALPHA *= alpha;
	ALPHA *= texture(mask, UV).r;
	ALBEDO = vec3(1.0);

	{
		float fade_distance = length(VERTEX);
		const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
		float fade = clamp(smoothstep(30.0, 25.0, fade_distance), 0.0, 1.0);
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
	}
}
