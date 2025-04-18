/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [
		{
      "NAME" : "speed",
      "TYPE" : "float",
      "MAX" : 3,
      "DEFAULT" : 1,
      "MIN" : 0
    },
    {
      "NAME" : "INTENSITY",
      "TYPE" : "float",
      "MAX" : 2.0,
      "DEFAULT" : 0.29999999999999999,
      "MIN" : 0
    },
    {
      "NAME" : "mod_contr",
      "TYPE" : "float",
      "MAX" : 30.0,
      "DEFAULT" : 1.0,
      "MIN" : 0.8
    }
  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#13531.3"
}
*/


#ifdef GL_ES
precision mediump float;
#endif

#define M_PI 3.141592653589793

#define NUM_SAMPLES 2


//#define INTENSITY 0.3

float rand(vec3 co){
    return fract(sin(dot(co.xyz,vec3(80,10000,91.1743))) * 44.4);
}

float fetch(vec2 uv) {
	vec2 d = abs(uv - vec2(0.5));
	return step(0.0, (max(d.x,d.y)-0.2));
}

vec2 offset_spiral(float x) {
	float a = x * 2.0 * M_PI * 0.3819444 * 521.0;
	return vec2(cos(a),sin(a))*pow(x,1.0/1.618);
}

#define offset offset_spiral

float linsmoothtri(float x) {
    return smoothstep(0.0,1.0,abs(mod(x,2.0) - 1.0));
}

void main(void) {
	vec2 uv = ( isf_FragNormCoord);
	vec2 c = uv;
	float aspect = RENDERSIZE.x / RENDERSIZE.y;
	uv -= 0.5;
	uv.x *= aspect;
	uv += 0.5;
	
	float color1 = 0.0;
	float f = mod_contr / float(NUM_SAMPLES);
	float o = 0.0;
	o = f * (rand(vec3(uv,mod((TIME)*speed,5.5))));
	float s = mix(0.0, INTENSITY, linsmoothtri(uv.y+(TIME*speed))); 
	for (int i = 0; i < NUM_SAMPLES; ++i) {
		float j = float(i) * f;
		color1 += fetch(uv + offset(j+o)*s);		
	}
	gl_FragColor = vec4(vec3(pow(color1 * f,1.2)), 1.0);
}