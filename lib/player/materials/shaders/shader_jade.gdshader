shader_type spatial;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D mask: hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 base_color: source_color;
uniform vec4 swirl_color: source_color;
uniform vec4 cloud_color: source_color;
uniform vec4 fresnel_color: source_color;
uniform float cloud_scale = 1.0;
uniform float speed_scale = 0.05;
uniform vec3 emission_color: source_color = vec3(0.0);
uniform bool clear_coat = false;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal),
		normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	vec2 wobble = texture(mask, UV * 0.1 + TIME * speed_scale).rg;
	vec3 base_texture = base_color.rgb;
	vec3 swirl_texture = swirl_color.rgb * texture(mask, (UV + wobble * 0.3) * 0.3 + TIME * speed_scale).r;

	ALBEDO = mix(base_texture, swirl_texture, 0.5);
	ALBEDO += fresnel(3.4, NORMAL, VIEW) * fresnel_color.rgb;

	vec3 cloud_texture = cloud_color.rgb * texture(mask, (SCREEN_UV + wobble * 0.1) * cloud_scale + TIME * speed_scale).r;
	cloud_texture = pow(cloud_texture, vec3(4.0));
	ALBEDO += cloud_texture * 0.5;

	METALLIC = 0.5;
	SPECULAR = 0.0;

	if (clear_coat == true) {
		SPECULAR = pow(texture(mask, UV * 1.1).r, 2.0);
		ROUGHNESS = texture(mask, UV * 1.1).r;
		METALLIC = texture(mask, UV * 1.1).r;
	}
	EMISSION = ALBEDO * 0.5;

	{
		// Distance Fade: Pixel Dither
		float fade_distance = length(VERTEX);
		const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
		float fade = clamp(smoothstep(0.3, 0.4, fade_distance), 0.0, 1.0);
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
	}
}
