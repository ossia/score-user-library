/*{
  "CREDIT": "by mojovideotech",
  "DESCRIPTION": "",
  "CATEGORIES": [
  		"generator"
  ],
  "INPUTS": [
    {
      "NAME": "size",
      "TYPE": "float",
      "DEFAULT": 20,
      "MIN": 9,
      "MAX": 99
    },
    {
      "NAME": "speed",
      "TYPE": "float",
      "DEFAULT": 1,
      "MIN": -1,
      "MAX": 3
    },
    {
      "NAME": "r",
      "TYPE": "float",
      "DEFAULT": 2,
      "MIN": 1,
      "MAX": 3
    },
    {
      "NAME": "g",
      "TYPE": "float",
      "DEFAULT": 2,
      "MIN": 1,
      "MAX": 3
    },
    {
      "NAME": "b",
      "TYPE": "float",
      "DEFAULT": 2,
      "MIN": 1,
      "MAX": 3
    },
    {
      "NAME": "seed",
      "TYPE": "point2D",
      "MAX": [ 2000, 2000 ],
      "MIN": [ 1, 1 ],
      "DEFAULT": [ 111, 333 ]
    }
  ]
}*/


////////////////////////////////////////////////////////////
// ALifeLEDWall  by mojovideotech
//
// based on:
// glslsandbox.com/\e#25692.0
//
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0
////////////////////////////////////////////////////////////


float rand(vec2 co) {
  return fract(tan(dot(co.xy, vec2(seed))) * log2(TIME));
}

void main (void) {
	vec2 v = gl_FragCoord.xy / size;
	vec3 brightness = vec3 ( fract(rand(floor(v)) + TIME / 1.1 * speed), 
							fract(rand(floor(v)) + TIME / 1.2 * speed), 
							fract(rand(floor(v)) + TIME / 1.3 * speed));
	brightness *= 0.5 - distance(fract(v), vec2(0.45, 0.45));
	gl_FragColor = vec4(brightness.r*r, brightness.g*g, brightness.b*b, 1.0);
}