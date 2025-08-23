shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_lambert, specular_schlick_ggx, shadows_disabled;

uniform sampler2D tex: filter_linear_mipmap, repeat_disable;

void fragment() {
	ALBEDO = texture(tex, UV2).rgb * 0.5;
	SPECULAR = 0.0;
	METALLIC = 0.0;
}
