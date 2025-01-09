shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, ambient_light_disabled, shadows_disabled;

uniform sampler2D gradient_h: hint_default_white;
uniform sampler2D gradient_v: hint_default_white;
uniform sampler2D noise_texture: hint_default_white;
uniform float noise_scale = 0.5;
uniform float alpha = 0.7;

void fragment() {
	// Called for every vertex the material is visible on.
	ALPHA *= texture(gradient_h, UV).r;
	ALPHA *= texture(gradient_v, UV).r;
	ALPHA *= texture(noise_texture, UV * noise_scale + TIME * vec2(-0.01, -0.02)).r;
	ALPHA *= alpha;
	ALBEDO = vec3(1.0);
}
