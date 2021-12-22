/*{
    "CATEGORIES": [
        "2d",
        "generator",
        "spirograph",
        "radial",
        "rotation"
    ],
    "CREDIT": "by izenme",
    "DESCRIPTION": "Moire Spirograph",
    "INPUTS": [
        {
            "DEFAULT": [
                0,
                0
            ],
            "MAX": [
                1,
                1
            ],
            "MIN": [
                -1,
                -1
            ],
            "NAME": "center",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": 12.32,
            "MAX": 16,
            "MIN": 1,
            "NAME": "freq",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.1,
            "MAX": 0.5,
            "MIN": 0.01,
            "NAME": "radius1",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.25,
            "MAX": 1.99,
            "MIN": 0.01,
            "NAME": "radius2",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.6,
            "MAX": 1.99,
            "MIN": 0.01,
            "NAME": "radius3",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.01,
            "MAX": 0.1,
            "MIN": -0.1,
            "NAME": "rate",
            "TYPE": "float"
        },
        {
            "DEFAULT": 58.93,
            "MAX": 200,
            "MIN": 1,
            "NAME": "loops",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.005,
            "MAX": 0.01,
            "MIN": 0.001,
            "NAME": "thickness",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.875,
            "MAX": 1,
            "MIN": 0,
            "NAME": "nudge",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.125,
            "MAX": 1,
            "MIN": 0,
            "NAME": "moire",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3,
            "MAX": 10,
            "MIN": -10,
            "NAME": "colorMap",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/

//////////////////////////////////////////////
// SpirographSpectrum by mojovideotech
//
// based on :
// www.shadertoy.com/\view/\lddGD4
//
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
/////////////////////////////////////////////


#define 	twpi  	6.283185307179586  	// two pi, 2*pi
#define 	pi   	3.141592653589793 	// pi


void main() {

	vec2 uv = (gl_FragCoord.xy-RENDERSIZE.xy*0.5)  / RENDERSIZE.y - center ;
    
    float ang = (atan(-uv.y,-uv.x)/atan(1.0)*moire+0.5)+TIME*rate;
    float len = length(uv);
    vec3 col = vec3(0.0);
    for(float i = 0.0;i<200.;i+=1.0)
    {
    	float L = floor(loops);
    	float F = ceil(freq);
    	if (i >= L) break;
        float tag = (ang+i)*twpi;
        float tln = (cos((ang+i*(1.0-nudge))*F)*0.5+0.5)*(radius3-radius2)+radius2*(radius2-radius1)+radius1;
        vec2 pos = normalize(uv)*tln;
    	col += smoothstep(thickness,0.0,distance(uv,pos) * pow(length(uv),0.001)) * (cos(tag+vec3(0.0,twpi,2.0*twpi) / colorMap)* 0.5 + 0.5);
    }
	gl_FragColor = vec4(col,1.0);
}
