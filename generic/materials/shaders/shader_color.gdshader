shader_type spatial;
render_mode unshaded, shadows_disabled, fog_disabled, ambient_light_disabled, depth_test_disabled;

uniform vec4 color: source_color;

void fragment() {
	ALBEDO = color.rgb;
}
