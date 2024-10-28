shader_type canvas_item;
// Used for separators

uniform sampler2D gradient: filter_linear_mipmap;

void fragment() {
	COLOR.a *= texture(gradient, UV).r;
}
