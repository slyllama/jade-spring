shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D mask: hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 base_color: source_color;
uniform vec4 swirl_color: source_color;
uniform vec4 cloud_color: source_color;
uniform vec4 fresnel_color: source_color;
uniform float cloud_scale = 1.0;
uniform float speed_scale = 0.05;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal),
		normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	vec2 wobble = texture(mask, UV * 0.1 + TIME * speed_scale).rg;
	vec3 base_texture = base_color.rgb;
	vec3 swirl_texture = swirl_color.rgb * texture(mask, (UV + wobble * 0.3) * 0.3 + TIME * speed_scale).r;
	
	ALBEDO = mix(base_texture, swirl_texture, 0.5);
	ALBEDO += fresnel(2.7, NORMAL, VIEW) * fresnel_color.rgb;
	
	vec3 cloud_texture = cloud_color.rgb * texture(mask, (SCREEN_UV + wobble * 0.1) * cloud_scale + TIME * speed_scale).r;
	cloud_texture = pow(cloud_texture, vec3(4.0));
	ALBEDO += cloud_texture * 0.5;
}
