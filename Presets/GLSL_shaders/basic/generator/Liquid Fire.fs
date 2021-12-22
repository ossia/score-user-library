/*{
  "CREDIT": "by mojovideotech",
  "DESCRIPTION": "",
  "CATEGORIES": [
    "generator",
    "fire"
  ],
  "INPUTS": [
    {
      "NAME": "offset",
      "TYPE": "point2D",
      "DEFAULT": [
        -1,
        -1
      ],
      "MAX": [
        10,
        1
      ],
      "MIN": [
        -10,
        -1
      ]
    },
    {
      "NAME": "rate",
      "TYPE": "float",
      "DEFAULT": 2,
      "MIN": 0.25,
      "MAX": 5
    },
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 2,
      "MIN": 0.01,
      "MAX": 16
    },
    {
      "NAME": "density",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.3,
      "MAX": 1
    }
  ]
}*/

// LiquidFire2 by mojovideotech
// based on :
// glslsandbox.com/e#29962.1
// by @301z

#ifdef GL_ES
precision mediump float;
#endif

float rnd(vec2 n) 
{ 
	return fract(cos(dot(n, vec2(5.14229, 433.494437))) * 2971.215073);
}

float noise(vec2 n) 
{
	const vec2 d = vec2(0.0, 1.0);
	vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
	return mix(mix(rnd(b), rnd(b + d.yx), f.x), mix(rnd(b + d.xy), rnd(b + d.yy), f.x), f.y);
}

float fbm(vec2 n) {
	float total = 0.0, amplitude = 1.1739;
	for (int i = 0; i < 7; i++) 
	{
		total += noise(n) * amplitude;
		n += n;
		amplitude *= density;
	}
	return total;
}

void main() 
{
	vec3 uv = vec3(RENDERSIZE.x,RENDERSIZE.y,1500.);
	vec2 p = gl_FragCoord.xy * scale / uv.yz;
	float T = TIME*rate;
	const vec3 c1 = vec3(0.2, 0.3, 0.1); 
	const vec3 c2 = vec3(0.9, 0.1, 0.0);
	const vec3 c3 = vec3(0.2, 0.0, 0.0); 
	const vec3 c4 = vec3(1.0, 0.9, 0.0); 
	const vec3 c5 = vec3(0.1);
	const vec3 c6 = vec3(0.9);
	float q = fbm(p - T * 0.25); 
	vec2 r = vec2(noise(p + q + log2(T * 0.618) - p.x - p.y), fbm(p + q - abs(log2(T * 3.142))));
	vec3 c = mix(c1, c4, fbm(p + r-offset.x)) + mix(c3, c5, r.x) - mix(c2, c6, r.y);
	gl_FragColor = vec4(c * cos(1.0-offset.y * gl_FragCoord.y / uv.y),1.0);
}

