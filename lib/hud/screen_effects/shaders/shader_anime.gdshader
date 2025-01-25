shader_type canvas_item;

uniform sampler2D noise: filter_nearest, repeat_enable;
uniform sampler2D anime_texture: hint_default_black;
uniform float modulate_a = 0.2;

void fragment() {
	vec2 wobble = texture(noise, SCREEN_UV + TIME * 0.1).rg * 0.2;
	COLOR = texture(anime_texture, (UV + wobble * 0.1) * 0.95);
	COLOR.a = COLOR.a * modulate_a;
}
