shader_type canvas_item;

// --- Includes --- //
//#include "res://shaders/includes/generic_functions.gdshaderinc"

// --- Uniforms --- //
uniform vec4 shine_color: source_color = vec4(1.0, 1.0, 1.0, 0.25);

uniform float line_width: hint_range(0.0, 2.0, 0.01) = 0.1;
uniform float angle: hint_range(0.0, 6.28318530718, 0.1308996939) = 0.785398163397;

uniform float speed: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float wait_cycles: hint_range(0.0, 10.0, 0.1) = 1.0;

// --- Functions --- //
vec2 rotate_precalculated(vec2 _pos, float _sine, float _cosine) {
	return vec2(_pos.x * _cosine + _pos.y * -_sine, _pos.x * _sine + _pos.y * _cosine);
}

void fragment() {
	float sine = sin(angle);
	float cosine = cos(angle);
	float len = 1.5 - max(abs(sine), abs(cosine)) + line_width;
	float line = smoothstep(-line_width, line_width, 
			rotate_precalculated((UV*UV - vec2(0.5)), sine, cosine).y - mod(TIME * speed, (len * 2.0) * wait_cycles) + len);
	COLOR.rgb += shine_color.rgb * shine_color.a * vec3(line * (1.0 - line) * 4.0);
	
	//vec4 outline_color = vec4(1.0,1.0,1.0,1.0);
	//vec4 line_NW = vec4(outline_color.rgb, texture(TEXTURE, UV - TEXTURE_PIXEL_SIZE ).a);
	//vec4 line_SE = vec4(outline_color.rgb, texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE ).a);
	//vec4 line_NE = vec4(outline_color.rgb, texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x,-TEXTURE_PIXEL_SIZE.y) ).a);
	//vec4 line_SW = vec4(outline_color.rgb, texture(TEXTURE, UV + vec2(-TEXTURE_PIXEL_SIZE.x,TEXTURE_PIXEL_SIZE.y) ).a);
	//vec4 outline1 = mix(line_NW, line_SE, line_SE);
	//vec4 outline2 = mix(line_NE, line_SW, line_SW);
	//vec4 outline = mix(outline1, outline2, outline2);
	//COLOR.rgba = mix(COLOR, outline, (1.0 - COLOR.a));
}
