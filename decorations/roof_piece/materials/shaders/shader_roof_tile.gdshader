shader_type spatial;

uniform sampler2D tile_texture: hint_default_black, filter_linear_mipmap;
uniform sampler2D mask_texture: hint_default_black, filter_linear_mipmap;
uniform sampler2D tile_normal: hint_normal;
uniform vec4 albedo: source_color;
uniform float uv_scale = 1.0;
uniform float mask_dodge = 0.5;

vec3 color_dodge(vec3 base, vec3 blend){
	return base / (1.0 - blend);
}


void fragment() {
	vec2 uv = UV * uv_scale;
	ALBEDO = texture(tile_texture, uv).rgb;
	ALBEDO *= albedo.rgb;
	ALBEDO = color_dodge(ALBEDO, texture(mask_texture, UV).rgb * mask_dodge);
	
	NORMAL = texture(tile_normal, uv).rgb;
	SPECULAR = 0.0;
	//METALLIC = 0.5;
	//SPECULAR = 0.5;
}
