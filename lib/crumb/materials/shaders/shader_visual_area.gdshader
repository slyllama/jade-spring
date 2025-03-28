shader_type spatial;
render_mode blend_mix, ambient_light_disabled, fog_disabled, unshaded,
shadows_disabled, cull_disabled;
// Visual area

uniform sampler2D mask_texture: source_color;
uniform sampler2D vertical_mask: hint_default_white;
uniform vec4 color: source_color;
uniform vec2 uv_scale = vec2(3.6, 3.6);
uniform float exponent = 2.0;
uniform float time_scale = 0.07;

uniform float distance_fade_min : hint_range(0.0, 4096.0, 0.01);
uniform float distance_fade_max : hint_range(0.0, 4096.0, 0.01);

void fragment() {
	ALPHA = texture(mask_texture, UV * vec2(uv_scale) + vec2(0, TIME * time_scale)).r;
	ALPHA = pow(ALPHA, exponent);
	//ALPHA += 0.01;
	ALPHA *= texture(vertical_mask, UV).r;
	ALBEDO = color.rgb;

	{
		// Distance Fade: Pixel Dither
		float fade_distance = length(VERTEX);
		// Use interleaved gradient noise, which is fast but still looks good.
		const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
		float fade = clamp(smoothstep(9.0, 8.0, fade_distance), 0.0, 1.0);
		// Use a hard cap to prevent a few stray pixels from remaining when past the fade-out distance.
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
	}
}
