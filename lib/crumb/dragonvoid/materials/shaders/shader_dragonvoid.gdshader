shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded, shadows_disabled, ambient_light_disabled, fog_disabled;

uniform sampler2D v_gradient_texture: hint_default_black;
uniform sampler2D h_gradient_texture: hint_default_black;
uniform sampler2D smoke_texture: hint_default_black;
uniform float speed = 0.21;

void fragment() {
	ALBEDO = vec3(0.0);
	ALPHA *= texture(v_gradient_texture, UV).r;
	ALPHA *= texture(h_gradient_texture, UV).r;
	ALPHA *= texture(smoke_texture, UV * vec2(4.0, 1.0) * 0.35 + TIME * vec2(speed, 0.0)).r;
}
