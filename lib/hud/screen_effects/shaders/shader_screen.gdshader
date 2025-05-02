shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform sampler2D grain_mask: hint_default_black;
uniform float grain_strength: hint_range(0.0, 1.0) = 1.0;

uniform float vignette_feather: hint_range(0.01, 0.5) = 0.25;
uniform float vignette_midpoint: hint_range(0.0, 1.0) = 0.5;
uniform float vignette_alpha: hint_range(0.0, 1.0) = 0.9;
uniform float displacement: hint_range(0.0, 8.0) = 0.0;

uniform vec2 ripple_center = vec2(0.5, 0.5);
uniform float ripple_force: hint_range(0.0, 0.02) = 0.01;
uniform float ripple_size: hint_range(0.0, 2.0) = 0.5;
uniform float ripple_feather: hint_range(-0.2, 0.1) = 0.0;

float circle(vec2 position, float radius, float feather) {
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}

void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y * 1.5;
	vec2 scaled_uv = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	float mask = (1.0 - smoothstep(ripple_size - 0.1, ripple_size - ripple_feather, length(scaled_uv - ripple_center))) *
		smoothstep(ripple_size - 0.2, ripple_size - 0.1, length(scaled_uv - ripple_center));
	vec2 disp = normalize(scaled_uv - ripple_center) * ripple_force * mask;
	//COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);

	vec2 r_displacement = vec2(0.0, displacement);
	vec2 g_displacement = vec2(displacement, 0.0);
	vec2 b_displacement = vec2(-displacement, 0.0);

	float r = texture(SCREEN_TEXTURE, SCREEN_UV - disp + vec2(SCREEN_PIXEL_SIZE * r_displacement), 0.0).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV - disp + vec2(SCREEN_PIXEL_SIZE * g_displacement), 0.0).g;
	float b = texture(SCREEN_TEXTURE, SCREEN_UV - disp + vec2(SCREEN_PIXEL_SIZE * b_displacement), 0.0).b;

	COLOR = vec4(r, g, b, 1.0);
	COLOR = mix(COLOR, vec4(1.0, 1.0, 1.0, 1.0), texture(grain_mask, UV).r * grain_strength);
	float vignette = circle(UV, vignette_midpoint, vignette_feather);
	COLOR = mix(COLOR, vec4(vec3(0.0), 1.0), vignette * vignette_alpha);
}
