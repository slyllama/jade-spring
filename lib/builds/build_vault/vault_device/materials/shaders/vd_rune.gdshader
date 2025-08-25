shader_type spatial;
render_mode unshaded;

uniform sampler2D rune_texture;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D wobble_texture: repeat_enable;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		MAIN_CAM_INV_VIEW_MATRIX[0],
		MAIN_CAM_INV_VIEW_MATRIX[1],
		MAIN_CAM_INV_VIEW_MATRIX[2],
		MODEL_MATRIX[3]);
	
	//MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
		//vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
		//vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
		//vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
		//vec4(0.0, 0.0, 0.0, 1.0));
	//MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

float circle(vec2 position, float radius, float feather) {
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}

void fragment() {
	vec2 og_uv = UV;
	og_uv -= vec2(0.5);
	float uv_x = sqrt(dot(og_uv, og_uv)) * 2.0;
	float uv_y = (atan(og_uv.x, og_uv.y) / -3.14) * 0.5 + 0.5;
	float wobble = texture(wobble_texture, UV + TIME * 0.1).r;
	
	vec2 _w = vec2(uv_x + TIME * 0.35 + wobble * 0.05, uv_y - wobble * 0.01);
	vec2 _x = texture(wobble_texture, _w).rg;
	vec3 _m = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	
	ALBEDO = mix(texture(SCREEN_TEXTURE, SCREEN_UV + _x * 0.1).rgb, _m, circle(UV, 0.18, 0.2));
	ALBEDO *= (1.0 + texture(rune_texture, UV + wobble * 0.03).a * 10.0);
	ALBEDO = clamp(ALBEDO, vec3(0.0), vec3(1.0));
}
