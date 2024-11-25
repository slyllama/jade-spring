shader_type canvas_item;

uniform sampler2D paint_mask_texture: hint_default_white, repeat_enable, filter_linear_mipmap;
uniform sampler2D paint_mask_gradient: hint_default_white, repeat_disable, filter_linear_mipmap;
uniform float paint_mask_exponent: hint_range(0.01, 10.0) = 1.0;

void fragment() {
	float paint_mask = texture(paint_mask_texture, UV).r;
	paint_mask = pow(paint_mask, paint_mask_exponent / texture(paint_mask_gradient, UV).r);
	if (paint_mask_exponent > 0.01) {
		COLOR.a *= paint_mask;
	}
}
