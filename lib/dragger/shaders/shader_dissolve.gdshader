shader_type canvas_item;

uniform sampler2D paint_mask: hint_default_black, repeat_enable, filter_linear_mipmap;
uniform float paint_exponent: hint_range(0.0, 10.0) = 1.0;
uniform float alpha: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float paint_mask_value = texture(paint_mask, UV).r;
	
	if (paint_exponent > 0.0) {
		paint_mask_value = pow(paint_mask_value, paint_exponent);
		COLOR.a *= paint_mask_value * alpha;
	}
	
	if (paint_exponent >= 10.0) {
		COLOR.a = 0.0;
	}
	
	COLOR.a *= 0.67; // reduce alpha (so you can see behind the arrows
}
