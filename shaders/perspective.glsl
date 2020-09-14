uniform float depth;

vec4 effect( vec4 color, Image tex, vec2 texcoord, vec2 scoord ){

	vec2 coordinates;
	float pixelDistanceX;
	float pixelDistanceY;
	float offset;
	float dir;

	pixelDistanceX = distance(texcoord.x, 0.5);
	pixelDistanceY = distance(texcoord.y, 0.5);

	offset = (pixelDistanceX*0.2) * pixelDistanceY;

	if (texcoord.y <= 0.5)
		dir = 1.0;
	else
		dir = -1.0;

	coordinates = vec2(texcoord.x, texcoord.y + pixelDistanceX*(offset*depth*dir));

	return color * Texel(tex, coordinates);
}