shader_type canvas_item;

uniform float alpha = 1;
uniform bool menu = false;

void fragment() {
	COLOR = vec4(0, 0, 0, alpha);
	vec2 adj = UV - 0.5;
	
	COLOR.a *= adj.x * adj.x + adj.y * adj.y;
	
	if (menu) {
		COLOR.a /= 1.5;
		COLOR.a += 1.0 / 3.0;
	}
	else
		COLOR.a *= 2.0;
}
