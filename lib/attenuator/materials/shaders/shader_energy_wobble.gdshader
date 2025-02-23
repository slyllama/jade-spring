shader_type canvas_item;

uniform sampler2D noise: filter_linear_mipmap, repeat_enable;

void fragment() {
	vec2 wobble = texture(noise, SCREEN_UV * 0.45 + TIME * 0.04).rg * 0.2;
	COLOR = texture(TEXTURE, (UV + wobble * 0.4) * 0.95);
}
	