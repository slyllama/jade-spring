shader_type spatial;

uniform sampler2D ao_mask_texture: filter_linear_mipmap;
uniform sampler2D stain_texture: filter_linear_mipmap, repeat_enable;
uniform vec4 colour_1: source_color;
uniform vec4 colour_2: source_color;
uniform float uv_scale = 1.0;

void fragment() {
	SPECULAR = 0.0;
	ALBEDO = mix(colour_1.rgb, colour_2.rgb,
		texture(stain_texture, UV * uv_scale).r);
	ALBEDO += texture(ao_mask_texture, UV).rgb * 0.2;
}

