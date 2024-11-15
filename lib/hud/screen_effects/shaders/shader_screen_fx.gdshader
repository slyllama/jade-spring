shader_type canvas_item;

uniform sampler2D swirl_texture: filter_linear_mipmap, repeat_enable;
uniform float alpha_exponent: hint_range(0.0, 10.0) = 1.0;

void fragment() {
	COLOR.a *= pow(texture(swirl_texture, UV * vec2(2.0, 1.0) * 2.6 + TIME * 0.03).r, alpha_exponent);
}

