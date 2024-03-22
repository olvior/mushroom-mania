shader_type canvas_item;

uniform vec2 scroll = vec2(0.1,0.1);
uniform vec2 scroll2 = vec2(0.1,0.1);
uniform sampler2D noise: repeat_enable;
uniform sampler2D noise2: repeat_enable;
void fragment() {
	
	vec4 Texture = texture(noise2,UV + scroll * TIME);
	vec4 Noise = texture(noise,UV*cos(scroll2 * TIME*10.0)+sin(TIME));
	vec4 energy = Texture*Noise;
	COLOR = vec4(vec3(Noise.grg),energy.a*0.5);
}
