shader_type canvas_item;

uniform sampler2D noise: filter_linear_mipmap, repeat_enable;
uniform float dissolve_value: hint_range(0.0, 1.0) = 0.0;
uniform float wobble_scale = 0.45;
uniform float strength: hint_range(0.0, 1.0) = 0.4;
uniform vec3 color: source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	vec2 wobble = texture(noise, SCREEN_UV * wobble_scale + TIME * 0.04).rg * 0.2;
	float dissolve = texture(noise, SCREEN_UV - TIME * 0.01).r;
	float _dv = 1.0 - dissolve_value;
	
	COLOR = texture(TEXTURE, (UV + wobble * strength) * 0.95);
	COLOR.rgb *= color;
	float _original_alpha = COLOR.a;
	COLOR.a *= pow(dissolve, _dv * 10.0);
	if (_dv == 1.0) {
		COLOR.a = 0.0;
	}
	if (_dv == 0.0) {
		COLOR.a = _original_alpha;
	}
}
	