shader_type canvas_item;

uniform float blur : hint_range(0,6) = .8;

void fragment(){
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, blur);
	COLOR = color;
}