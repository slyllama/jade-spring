// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, unshaded, shadows_disabled, ambient_light_disabled, fog_disabled;

uniform sampler2D ray_mask_texture: hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 albedo_uv_scale = vec2(1.0, 1.0);
uniform sampler2D x_gradient_texture: hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D y_gradient_texture: hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D albedo_texture: hint_default_black, filter_linear_mipmap, repeat_enable;

void vertex() {
	// Billboard Mode: Y-Billboard
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			vec4(normalize(cross(vec3(0.0, 1.0, 0.0), MAIN_CAM_INV_VIEW_MATRIX[2].xyz)), 0.0),
			vec4(0.0, 1.0, 0.0, 0.0),
			vec4(normalize(cross(MAIN_CAM_INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
			MODEL_MATRIX[3]);

	// Billboard Keep Scale: Enabled
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	float ray_mask = texture(ray_mask_texture, UV * uv_scale + TIME * vec2(0.0, 1.0) * 0.1).r;
	ALBEDO = texture(albedo_texture, UV * albedo_uv_scale + vec2(0.0, TIME * 0.1)).rgb;
	ALPHA = ray_mask;
	ALPHA *= texture(x_gradient_texture, UV).r;
	ALPHA *= texture(y_gradient_texture, UV).r;
}
