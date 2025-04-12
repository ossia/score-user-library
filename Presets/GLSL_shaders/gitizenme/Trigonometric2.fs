/*{
  "CREDIT": "by mojovideotech",
  "CATEGORIES": [
  	"generator",
    "procedural",
    "2d",
    "trigonometric"
  ],
  "DESCRIPTION": "from https://www.shadertoy.com/view/Mdl3RH by iq.  Trigonometric iterations. Or, some abstract stuff inspired made after Pickover's popcorn formulas.",
  "INPUTS": [
    {
      "MAX": [
        10,
        10
      ],
      "MIN": [
        -10,
        -10
      ],
      "DEFAULT": [
        0.5,
        0.4
      ],
      "NAME": "matrix",
      "TYPE": "point2D"
    },
    {
      "NAME": "seed1",
      "TYPE": "float",
      "DEFAULT": 250,
      "MIN": 10,
      "MAX": 500
    },
    {
      "NAME": "seed2",
      "TYPE": "float",
      "DEFAULT": 45,
      "MIN": 1,
      "MAX": 50
    },
    {
      "NAME": "offset1",
      "TYPE": "float",
      "DEFAULT": -1,
      "MIN": -3,
      "MAX": 3
    },
    {
      "NAME": "offset2",
      "TYPE": "float",
      "DEFAULT": 2,
      "MIN": -3,
      "MAX": 3
    },
    {
      "NAME": "offset3",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": -5,
      "MAX": 5
    },
    {
      "NAME": "depth",
      "TYPE": "float",
      "DEFAULT": 0.99,
      "MIN": 0.5,
      "MAX": 1.75
    },
    {
      "NAME": "color1",
      "TYPE": "float",
      "DEFAULT": 0.33,
      "MIN": -0.5,
      "MAX": 0.5
    },
    {
      "NAME": "color2",
      "TYPE": "float",
      "DEFAULT": -0.33,
      "MIN": -0.5,
      "MAX": 0.5
    },
    {
      "NAME": "color3",
      "TYPE": "float",
      "DEFAULT": 0.33,
      "MIN": 0,
      "MAX": 1
    },
    {
      "NAME": "density",
      "TYPE": "float",
      "DEFAULT": 0.99,
      "MIN": 0.025,
      "MAX": 1.25
    },
    {
      "NAME": "multiplier",
      "TYPE": "float",
      "DEFAULT": 2,
      "MIN": 1,
      "MAX": 120
    },
    {
      "NAME": "rate",
      "TYPE": "float",
      "DEFAULT": 0,
      "MIN": -0.1,
      "MAX": 0.1
    }
  ]
}*/


////////////////////////////////////////////////////////////
// Trigonometric2  by mojovideotech
//
// based on :
// shadertoy.com/\Mdl3RH  by IQ - www.iquilezles.org
//
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0
////////////////////////////////////////////////////////////



vec2 iterate( in vec2 p, in vec4 t ) {
    return p - (1.0-depth)*cos(t.yz + p.x*p.y + cos(mix(t.zw,p.yx,matrix)+1.5*3.1415927*p.yx)+p.yy*length(p.yx) );
}

void main() 
{
	vec2 q = isf_FragNormCoord;
	vec2 p = offset1 + offset2*q;
	p.x *= RENDERSIZE.x/RENDERSIZE.y;
    p *= offset3;	
    float tt = (rate*TIME-sqrt(TIME/seed1))*seed2;
    vec4 t = 0.05*tt*vec4( p.y,floor(multiplier), matrix.y, matrix.x ) + vec4(0.6,2.0,3.0,1.0);
    vec2 z = p;
	vec3 s = vec3(0.0);
	for( int i=0; i<96; i++ ) {
		z = iterate( z, t );
		float d = dot( z-p, z-p ); 
		s.x += 1.0/(0.1+d);
		s.y += sin(atan( p.x-z.x, p.y-z.y ));
		s.z += exp(-0.2*d );
	}
    s /= 100.0;
	vec3 cola = 0.5 + 0.5*cos( vec3(0.5+color2,0.5,(1.0-(color2+0.5))) + 2.5 + s.z*6.2831 );
	cola *= 0.5 + 0.5*s.y;
    cola *= s.x;
    cola *= 0.94+density*sin(seed2*length(z));
	vec3 nor = normalize( vec3( (s.x), 0.02, (s.x) ) );
	vec3 dif = mix( nor*cola, vec3(color3,abs(color1+color2),1.0-color3),color3 );
	cola += 0.5*vec3(dif);
	cola *= 0.3 + 0.7*pow( seed1*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.2 );
  	vec3 colb = cola*(vec3(1.5 - nor));
	vec3 col = mix(cola,colb,0.5+color1);
	
	gl_FragColor = vec4( col, 1.0 );
}