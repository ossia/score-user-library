// SaturdayShader Week 31 : WaveShapes
// by Joseph Fiola (http://www.joefiola.com)
// 2016-03-26
//modified by Sprohgis

// Based on shader by Shadertoy user smb02dunnal entitiled "Electro-Prim's" - https://www.shadertoy.com/view/Mll3WS
// https://twitter.com/AlexWDunn
// Sadly it's not working with VDMX. Gan somone please make it work.


/*{
  "CREDIT": "Joseph Fiola",
  "DESCRIPTION": "",
  "CATEGORIES": [
    "Generator"
  ],
  "INPUTS": [
    {
      "NAME": "shape",
      "TYPE": "long",
      "VALUES": [
        0,
        1
      ],
      "LABELS": [
        "triangle",
        "square"
      ],
      "DEFAULT": 0
    },
    {
      "NAME": "triside1",
      "TYPE": "float",
      "DEFAULT": 3,
      "MIN": 0,
      "MAX": 3
    },
    {
      "NAME": "squareside1",
      "TYPE": "float",
      "DEFAULT": 1,
      "MIN": 0,
      "MAX": 10
    },
    {
      "NAME": "zoom",
      "TYPE": "float",
      "DEFAULT": 1,
      "MIN": 0,
      "MAX": 10
    },
    {
      "NAME": "rotate",
      "TYPE": "float",
      "DEFAULT": 0,
      "MIN": 0,
      "MAX": 1
    },
    {
      "NAME": "twist",
      "TYPE": "float",
      "DEFAULT": 0.02,
      "MIN": 0,
      "MAX": 1
    },
    {
      "NAME": "tunnel",
      "TYPE": "float",
      "DEFAULT": 1.1,
      "MIN": 0.25,
      "MAX": 1.75
    },
    {
      "NAME": "thickness",
      "TYPE": "float",
      "DEFAULT": 0.003,
      "MIN": 0,
      "MAX": 0.2
    },
    {
      "NAME": "amplitude",
      "TYPE": "float",
      "DEFAULT": 0,
      "MIN": 0,
      "MAX": 100
    },
    {
      "NAME": "frequency",
      "TYPE": "float",
      "DEFAULT": 0,
      "MIN": 0,
      "MAX": 50
    },
    {
      "NAME": "band",
      "TYPE": "float",
      "DEFAULT": 0,
      "MIN": -0.5,
      "MAX": 1
    },
    {
      "NAME": "pos",
      "TYPE": "point2D",
      "DEFAULT": [
        0.5,
        0.5
      ],
      "MIN": [
        0,
        0
      ],
      "MAX": [
        1,
        1
      ]
    }
  ]
}*/

// line commented out enabling compile in xLights by Old Salt
// precision mediump float;

#define PI 3.14159265359
#define TWO_PI 6.28318530718

float electro(vec2 uv, float d, float f, float o, float a, float b)
{
    
    float theta = atan(uv.y,uv.x);
    
    float amp = smoothstep(0.0, 1.0, (sin(theta + TIME * PI)*0.5+0.5)-b)*a;
    float phase = d + sin(theta * f + o + TIME * PI) * amp;
    
    return sin(clamp(phase, 0.0, PI*2.0) + PI/2.0) + 1.0005;
}

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

void main() 
{
   const float radius = 0.1;
    
  	vec2 uv = isf_FragNormCoord;
	uv -= vec2(pos);
	uv.x *= RENDERSIZE.x/RENDERSIZE.y;
       
   uv = rotate2d(rotate*-TWO_PI) * uv;
   uv *= zoom;
   
   float grey = 0.0;
   float alpha = 1.0;

	for(int i = 0; i < 20; i++) {
	
   		float d = 0.0;
		
		//triangle
		if (shape == 0){
			float root2 = sqrt(triside1);
			d =  dot(uv, vec2(0.0,-2.0));
    		d = max(d, dot(uv, vec2(-root2,1.0)));
    		d = max(d, dot(uv, vec2( root2,1.0)));
		}
		
		//square
		if (shape == 1){
	    	d = max(abs(uv).x*squareside1, abs(uv).y);
		}

		grey += 1.0 - smoothstep(0.0, thickness, electro(uv, d/radius, frequency, 0.0 * PI, amplitude, band));
    	grey += 1.0 - smoothstep(0.0, thickness, electro(uv, d/radius, frequency, 0.5 * PI, amplitude, band));
    	grey += 1.0 - smoothstep(0.0, thickness, electro(uv, d/radius, frequency, 1.0 * PI, amplitude, band));
   	
    	
    	//tunnel
    	uv *= tunnel;
    	
    	//twist
    	uv = rotate2d(twist*-TWO_PI) * uv;
   	}
   	

   gl_FragColor = vec4(vec3(grey),1.0);
}

