extern number vars[2];
vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
	vec4 pixel = Texel(tex, vec2(tc.x + sin(tc.y*15.0 - vars[0])*0.001 * vars[1], tc.y));

	return pixel;
}