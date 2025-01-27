// Exposure-based light ray
shader_type spatial;
render_mode blend_premul_alpha, unshaded, fog_disabled, cull_disabled, ambient_light_disabled, shadows_disabled;

uniform sampler2D gradient_h: hint_default_white;
uniform sampler2D gradient_v: hint_default_white;
uniform sampler2D noise_texture: hint_default_white;
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform float noise_scale = 0.5;
uniform float alpha = 0.7;
uniform float multiplier = 5.0;

void fragment() {
	float rays = alpha;
	rays *= texture(gradient_h, UV).r;
	rays *= texture(gradient_v, UV).r;
	rays *= texture(noise_texture, UV * noise_scale + TIME * vec2(-0.01, -0.02)).r;

	ALBEDO = texture(screen_texture, SCREEN_UV).rgb;
	ALBEDO += ALBEDO * rays * 20.0;
}
