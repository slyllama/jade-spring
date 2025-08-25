shader_type spatial;
render_mode unshaded;

uniform sampler2D stars_texture: repeat_enable;
uniform sampler2D wobble_texture: repeat_enable;
uniform float uv_scale = 2.0;


float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(
		dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void fragment() {
	float wobble = texture(wobble_texture, UV * 0.1 + TIME * 0.02).r;
	ALBEDO = pow(texture(stars_texture, UV * uv_scale + wobble * 0.2).rgb, vec3(1.2));
	ALBEDO += pow(fresnel(1.5, NORMAL, VIEW), 3.0) * 0.45;
	ALBEDO = clamp(ALBEDO, vec3(0.0), vec3(1.0));
}
