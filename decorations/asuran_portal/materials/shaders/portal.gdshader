shader_type spatial;
render_mode cull_disabled, unshaded, shadows_disabled, fog_disabled, ambient_light_disabled;

uniform bool is_portal = true;

uniform sampler2D SCREEN_TEXTURE: filter_linear_mipmap, hint_screen_texture;
uniform sampler2D mask: filter_linear_mipmap, repeat_disable;
uniform sampler2D wobble_texture: filter_linear_mipmap, repeat_enable;
uniform vec3 tint: source_color;
uniform vec3 outer_tint: source_color;

float circle(vec2 position, float radius, float feather) {
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}

void fragment() {
	vec2 og_uv = UV;
	og_uv -= vec2(0.5);
	float uv_x = sqrt(dot(og_uv, og_uv)) * 2.0;
	float uv_y = (atan(og_uv.x, og_uv.y) / -3.14) * 0.5 + 0.5;
	
	float m = texture(mask, UV).r;
	float w = texture(wobble_texture, UV + TIME * 0.1).r;
	float oc = 1.0 - circle(UV, 0.45, 0.0); // outer circle
	
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV - vec2(
		uv_x + w * 0.18, uv_y - w * 0.18) * 4.0 + TIME * 0.1).rgb;
	ALBEDO = mix(ALBEDO, texture(SCREEN_TEXTURE, SCREEN_UV + w * 0.05).rgb, 1.0 - m);
	
	ALBEDO *= mix(tint, vec3(1.0), 0.9 - circle(UV, 0.12, 0.25));
	ALBEDO += (circle(UV, 0.35, 0.25) * oc) * outer_tint;
	ALBEDO *= 1.3;
	ALBEDO = mix(ALBEDO, texture(SCREEN_TEXTURE, SCREEN_UV).rgb, 1.0 - oc);
	ALBEDO = clamp(ALBEDO, 0.0, 1.0);
}
