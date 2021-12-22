/*{
  "CREDIT": "by mojovideotech",
  "DESCRIPTION": "",
  "CATEGORIES": [
  	"generator"	
  ],
  "INPUTS": [
    {
      "MAX": [
        2,
        2
      ],
      "MIN": [
        -2,
        -2
      ],
      "NAME": "center",
      "TYPE": "point2D"
    },
    {
      "MAX": 3,
      "MIN": -3.14,
      "DEFAULT": -3.11,
      "NAME": "cubesize",
      "TYPE": "float"
    },
    {
      "MAX": 20,
      "MIN": 3,
      "DEFAULT": 5.3,
      "NAME": "vanishingpoint",
      "TYPE": "float"
    },
    {
      "MAX": 0.9,
      "MIN": 0.01,
      "DEFAULT": 0.15,
      "NAME": "brightness",
      "TYPE": "float"
    },
    {
      "MAX": 2,
      "MIN": -2,
      "DEFAULT": 0.6,
      "NAME": "rate",
      "TYPE": "float"
    },
    {
      "MAX": 0.8,
      "MIN": 0.05,
      "DEFAULT": 0.47,
      "NAME": "tint",
      "TYPE": "float"
    },
    {
      "MAX": 3,
      "MIN": -6,
      "DEFAULT": -1.73,
      "NAME": "stretchx",
      "TYPE": "float"
    },
    {
      "MAX": 3,
      "MIN": 0.01,
      "DEFAULT": 2.6,
      "NAME": "stretchy",
      "TYPE": "float"
    },
    {
      "MAX": 3.5,
      "MIN": 0.95,
      "DEFAULT": 1.83,
      "NAME": "stretchz",
      "TYPE": "float"
    },
    {
      "MAX": 0.99,
      "MIN": 0.01,
      "DEFAULT": 0.49,
      "NAME": "overdrive",
      "TYPE": "float"
    },
    {
      "MAX": 5,
      "MIN": 0,
      "DEFAULT": 2.77,
      "NAME": "pov",
      "TYPE": "float"
    }
  ]
}*/



////////////////////////////////////////////////////////////
// CubicMatrixModulatorRedux  by mojovideotech
//
// based on :
// shadertoy/\XsB3Rm
//
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0
////////////////////////////////////////////////////////////

#define 	pi   	3.141592653589793  // pi
#define		qtpi	0.78539816339745	// quarter pi, pi/4, 45º

const int max_iterations = 150;
const float stop_threshold = 0.001;
const float grad_step = 0.01;
const float clip_far = 300.0;

float dist_field(vec3 p) {
    p = mod(p, 8.0) - 4.0;
    p = abs(p);
    float cube = length(max(p - 0.0667, 0.5));
    float xd = max(p.y-dot(-stretchz,stretchx),p.z);
    float yd = max(p.x-pow(stretchy,-stretchz),p.z);
    float zd = mix(p.x,p.y,stretchz);
    float beams = min(zd*cubesize, max(xd, yd)/mix(stretchz,stretchx,stretchy)) - cos(cubesize);
    	  beams *= min(zd/sin(cubesize), max(xd, yd)/mod(stretchx,-stretchy)+log2(cubesize));
    	  beams += min(zd, min(xd, yd)) /-rate;
    return min(beams, cube);
}

vec3 shading( vec3 v, vec3 eye ) {
	float s = v.x + v.y + v.z;
          s -= eye.x + eye.y * v.z;
	return vec3(mod(floor (s * 99.0),0.0+overdrive)-brightness);
}

float ray_marching( vec3 origin, vec3 dir, float start, float end ) {
	float depth = start;
	for ( int i = 0; i < max_iterations; i++ ) {
		float dist = dist_field( origin + dir * depth );
		if ( dist < stop_threshold ) {
			return depth;
		}
		depth += dist;
		if ( depth >= end) {
			return end;
		}
	}
	return end;
}

vec3 ray_dir( float fov, vec2 size, vec2 pos ) {
	vec2 xy = pos - size * center.xy;
	float cot_half_fov = tan( mod((( 270.0 - fov * 0.25 ) * pi - qtpi), (( 60.0 - fov * 0.5 ) * pos.x)));	
	float z = size.y * 0.67 * pow(pov,cot_half_fov);
	return normalize( vec3( xy, -z ) );
}

mat3 rotationXY( vec2 angle ) {
	vec2 c = cos( angle*stretchx );
	vec2 s = sin( angle*stretchy );
	return mat3(
		c.y      ,  0.0, -s.y,
		s.y * s.x,  c.x,  c.y * s.x,
		s.y * c.x, -s.x,  c.y * c.x
	);
}

void main(void)
{
	vec3 dir = ray_dir( stretchx, RENDERSIZE.xy, gl_FragCoord.xy);
	vec3 eye = vec3( 0.0, 0.0, 0.0 );
	float TT = TIME * rate;
	mat3 rot = rotationXY( vec2(TT * 0.005, TT * 0.0125));
	dir = rot * dir;
	eye = rot * eye;
    eye.z -=  mod(TT * 4.0, 8.0);
    eye.y = eye.x = 0.0;
	float depth = ray_marching( eye, dir, 1.75, clip_far);
	if ( depth >= clip_far ) { gl_FragColor = vec4(1.0); } 
   	else {
		vec3 pos = eye + dir * depth;
		gl_FragColor = vec4( shading( pos, eye ) , 1.0 );
        gl_FragColor += depth/clip_far * vanishingpoint;
    }
    gl_FragColor = vec4(vec3(0.9-tint, 0.1+tint, 1.0-abs(tint/3.0)) - gl_FragColor.zyx, 1.0);
    gl_FragColor += vec4(vec3(0.0+brightness, 0.3, 0.1+tint), 1.0);
}