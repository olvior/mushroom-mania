shader_type canvas_item;

void fragment() {
	COLOR.a = texture(TEXTURE,UV).a*abs(1.0-abs(cos(TIME))+0.5);
}
