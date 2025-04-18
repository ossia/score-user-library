/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#2876.0"
}
*/


#ifdef GL_ES
precision highp float;
#endif

uniform vec2 reyboard;


float thing(vec2 pos) 
{
	float ret = 0.0;
	pos.x = sqrt(pos.x / 3.14) * (sin(TIME * 0.5) ) / sign(pos.y) * tan(pos.x);
	pos.y = sin(pos.y * 13.14) + sign(pos.x) - sqrt(pos.y/pos.x);
	ret = max((pos.y * sin(TIME*5.)) + pos.x + sin(TIME * 0.1), sin(TIME));
	return ret;
}

void main(void) 
{
	vec2 position = ( isf_FragNormCoord *);
	vec2 world = position * 15.0;
	world.x *= RENDERSIZE.x / RENDERSIZE.y;
	float dist = thing(world)*0.06;

	gl_FragColor = vec4( dist, dist, dist, 1.0 );
}