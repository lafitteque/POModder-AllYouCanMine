shader_type canvas_item;

uniform sampler2D NORMAL_TEX :filter_linear_mipmap, hint_normal ; 

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

varying flat vec4 modulate;

void vertex() {
    modulate = COLOR;
}

void fragment() {
	vec2 suv = SCREEN_UV;
	vec4 c = texture(TEXTURE, UV);
	vec4 n = texture(NORMAL_TEX, UV);
	suv.x += (n.r - 0.5f) * 0.05;
	suv.y += (n.g - 0.5f) * 0.05;
	vec4 distort = texture(SCREEN_TEXTURE, suv);
	COLOR.rgb = distort.rgb;
	COLOR.a = c.a * modulate.a;
}