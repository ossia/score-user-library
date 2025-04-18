// SaturdayShader Week 29 : Wave Lines
// by Joseph Fiola (http://www.joefiola.com)
// 2016-03-05

// Based on "WAVES" Shadertoy by bonniem
// https://www.shadertoy.com/view/4dsGzH

/*{
	"CREDIT": "Joseph Fiola",
	"DESCRIPTION": "",
	"CATEGORIES": [
		"Generator"
	],
	"INPUTS": [
		{
			"NAME": "amp",
			"TYPE": "float",
			"DEFAULT": 1.0,
			"MIN": -20.0,
			"MAX": 20.0
		},
		{
			"NAME": "glow",
			"TYPE": "float",
			"DEFAULT": -1.0,
			"MIN": -20.0,
			"MAX": 0.0
		},
		{
			"NAME": "mod1",
			"TYPE": "float",
			"DEFAULT": 1.0,
			"MIN": 0.0,
			"MAX": 100.0
		},
		{
			"NAME": "mod2",
			"TYPE": "float",
			"DEFAULT": 0.0,
			"MIN": -1.0,
			"MAX": 1.0
		},
		{
			"NAME": "zoom",
			"TYPE": "float",
			"DEFAULT": 1.0,
			"MIN": 0.0,
			"MAX": 100.0
		},
		{
			"NAME": "rotateCanvas",
			"TYPE": "float",
			"DEFAULT": 0.0,
			"MIN": 0.0,
			"MAX": 1.0
		},
		{
			"NAME": "scroll",
			"TYPE": "float",
			"DEFAULT": 0.0,
			"MIN": 0.0,
			"MAX": 1.0
		},
		{
			"NAME": "pos",
			"TYPE": "point2D",
			"DEFAULT": [0.5,0.5],
			"MIN":[0.0,0.0],
			"MAX":[1.0,1.0]
		},
		{
			"NAME": "twisted",
			"TYPE": "float",
			"DEFAULT": 0.0,
			"MIN": -0.5,
			"MAX": 0.5
		}
	]
}*/


#define PI 3.14159265359
#define TWO_PI 6.28318530718

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

void main()
{
	vec2 uv = isf_FragNormCoord;
	uv -= vec2(pos);
	uv.x *= RENDERSIZE.x/RENDERSIZE.y;
	uv *= zoom; // Scale the coordinate system
	uv = rotate2d(rotateCanvas*-TWO_PI) * uv; 
	
	
	// waves
	vec3 wave_color = vec3(0.0);
	
	float wave_width = 0.01;
	//uv  = -1.0 + 2.0 * uv;
	//uv.y += 0.1;
	for(float i = 0.0; i < 10.0; i++) {
		
		uv = rotate2d(twisted*-TWO_PI) * uv; 

		uv.y +=  sin(sin(uv.x + i*mod1 + (scroll * TWO_PI) ) * amp + (mod2 * PI));
		wave_width = abs(1.0 / (50.0 * uv.y * glow));
		wave_color += vec3(wave_width, wave_width, wave_width);
	}
	
	gl_FragColor = vec4(wave_color, 1.0);
}