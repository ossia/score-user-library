/*{
    "CATEGORIES": [
        "generator",
        "sphere"
    ],
    "CREDIT": "by mojovideotech",
    "DESCRIPTION": "",
    "INPUTS": [
        {
            "DEFAULT": [
                0.5,
                0.3
            ],
            "MAX": [
                0.99,
                0.99
            ],
            "MIN": [
                0.01,
                0.01
            ],
            "NAME": "O",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.1,
                0.5
            ],
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0,
                0
            ],
            "NAME": "C",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": 9,
            "MAX": 36,
            "MIN": 0,
            "NAME": "R1",
            "TYPE": "float"
        },
        {
            "DEFAULT": 17,
            "MAX": 54,
            "MIN": 0,
            "NAME": "R2",
            "TYPE": "float"
        },
        {
            "DEFAULT": 2.0,
            "MAX": 5.0,
            "MIN": 1.1,
            "NAME": "zoom",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1.5,
            "MAX": 3,
            "MIN": -3,
            "NAME": "rate",
            "TYPE": "float"
        },
        {
            "DEFAULT": 64,
            "MAX":	72,
            "MIN": 24,
            "NAME": "depth",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.55,
            "MAX": 1.25,
            "MIN": 0.25,
            "NAME": "gamma",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2",
    "VSN": "2"
}
*/


////////////////////////////////////////////////////////////////////
// SpaceSpore  by mojovideotech
// v2.0 5/2020 ; optimized code, added uniforms
//
// based on :
// shadertoy.com/lslcWj   by LukeRissacher
//
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0
////////////////////////////////////////////////////////////////////


#define 	twpi  	6.283185307179586  	
#define 	R(p, a) p = p * cos(a) + vec2(-p.y, p.x) * sin(a)

float Swave(float w) { return 0.5 + 0.5 * sin(twpi * w); }

float Sdef(vec3 p) { return 1.0 - abs(sin(p.x) + sin(p.y) + sin(p.z)) * 0.333; }

float Smap(vec3 p, float s) {
    float dSphere = length(p) - 1.0;
    return max(dSphere, (0.95 - Sdef(s * p)) / s);
}

vec3 Scol(vec3 p) {
    float a = clamp((2.0 - length(p)) * 0.5, 0.0, 1.0);
    vec3 c = 0.5 + 0.5 * cos(twpi * cross(vec3(1.0, C.x, C.y), vec3(Swave(-a) * vec3(0.5, 1.0, 1.0))));
    return c * a;
}

vec3 rgb(vec3 c) { return c*c*c*(c*(c*6.0-15.0)+10.0); }

void main() {
	float TT = TIME * rate; 
	vec3 rd = normalize(vec3(2.0 * gl_FragCoord.xy - RENDERSIZE.xy, -min(RENDERSIZE.x,RENDERSIZE.y)));
    vec3 ro = vec3(0.0, 0.0, zoom); 
    R(rd.xz, O.x * -TT);
    R(ro.xz, O.x * -TT);
    R(rd.yz, O.y * TT);
    R(ro.yz, O.y * TT);
    float t = 0.0;
    vec3 col = vec3(0.0);
    float S = mix(R1, R2, Swave(0.05 * TT));
    for (int i = 0; i < 90; i++) {
    	if (float(i) >= floor(depth)) { break; }
        vec3 p = ro + t * rd;
        float d = Smap(p, S);
        if (t > 5.0 || d < 0.001) {
            break;
        }
        t += 0.8 * d;
        col += 0.05 * Scol(p);
    }
    gl_FragColor = vec4(pow(rgb(col),vec3(gamma)),1.0);
}
