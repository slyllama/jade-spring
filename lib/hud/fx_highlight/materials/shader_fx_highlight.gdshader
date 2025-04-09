shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D glow_texture: hint_default_white, repeat_disable, filter_linear_mipmap;
uniform sampler2D wobble_texture: hint_default_black, repeat_enable;
uniform float wobble_intensity: hint_range(0.0, 1.0) = 0.5;
uniform float wobble_time: hint_range(0.0, 1.0) = 0.2;
uniform vec3 color: source_color;

void fragment() {
	vec2 uv = texture(wobble_texture, UV * 0.5 + TIME * 0.04 * wobble_time).rg;
	vec4 plain_tex = texture(SCREEN_TEXTURE, SCREEN_UV).rgba;
	vec4 wobble_tex = texture(SCREEN_TEXTURE, SCREEN_UV + uv * wobble_intensity * 0.02).rgba;
	wobble_tex += texture(glow_texture, UV * 1.2 - vec2(0.12) + uv * wobble_intensity * 0.20).rgba * vec4(color, 1.0);
	COLOR = mix(plain_tex, wobble_tex, texture(glow_texture, UV).r);
}

