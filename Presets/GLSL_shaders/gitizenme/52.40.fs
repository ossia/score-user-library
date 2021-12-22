/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                0.3,
                0.15,
                0.1,
                1
            ],
            "LABEL": "Color A",
            "NAME": "colorA",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.1,
                0.05,
                0,
                1
            ],
            "LABEL": "Color B",
            "NAME": "colorB",
            "TYPE": "color"
        },
        {
            "DEFAULT": 3,
            "LABEL": "Depth Brightness",
            "MAX": 8,
            "MIN": 2,
            "NAME": "dBright",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0,
                0
            ],
            "LABEL": "dXY",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                -1,
                -1
            ],
            "NAME": "dXY",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": 0,
            "LABEL": "rotation",
            "MAX": 3.6,
            "MIN": -3.6,
            "NAME": "rotation",
            "TYPE": "float"
        },
        {
            "DEFAULT": 5,
            "LABEL": "zRate",
            "MAX": 10,
            "MIN": 0,
            "NAME": "zRate",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.8,
            "LABEL": "lDiff",
            "MAX": 1,
            "MIN": 0.1,
            "NAME": "lDiff",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "xAmp",
            "MAX": 3,
            "MIN": -3,
            "NAME": "xAmp",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3,
            "LABEL": "pAmp",
            "MAX": 10,
            "MIN": 0.5,
            "NAME": "pAmp",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.2,
            "LABEL": "xyAmp",
            "MAX": 1,
            "MIN": 0.1,
            "NAME": "xyAmp",
            "TYPE": "float"
        },
        {
            "DEFAULT": 64,
            "LABEL": "iterations",
            "MAX": 128,
            "MIN": 1,
            "NAME": "iterations",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/

mat2 rotate(float a) {
    float s=sin(a); 
    float c=cos(a);
    return mat2(c,-s,s,c);
}

float m(vec3 p) 
{ 
	p.z += zRate * TIME; 
    p.xy += dXY;
    p.xy *= rotate(rotation);
    // return length(.2 * sin(p.x - p.y) + cos(p / 3.)) - .8;
    return length(xyAmp * sin(p.x - p.y) + cos(p / pAmp) - .1 * sin(xAmp * p.x)) - lDiff;
 
}

void main() {
    vec3 d = .5 - vec3(gl_FragCoord.xy, 0) / RENDERSIZE.x;
    d.xy += dXY;
    d.xy *= rotate(rotation);
    vec3 o = d;

    for(int i = 0; i < int(iterations); i++) {
        o += m(o) * d;
    }

    vec3 cA = m(o + d) * vec3(colorA);
    vec3 cB = m(o * .5) * vec3(colorB);
    vec3 c = abs(clamp(cA, 0., 1.) + clamp(cB, 0., 1.));
    c *= (dBright * 4. - o.z / dBright);

    gl_FragColor = vec4(c, 1);
}
