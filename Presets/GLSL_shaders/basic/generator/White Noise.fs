/*{
    "CATEGORIES": [
        "Noise",
        "Utility"
    ],
    "CREDIT": "Tuxic",
    "DESCRIPTION": "generates a basic white noise",
    "INPUTS": [
        {
            "DEFAULT": 12.9898,
            "MAX": 100,
            "MIN": 0,
            "NAME": "seed",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/

// Author: Rich Harris
// License: MIT

// http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
float random(vec2 co)
{
    highp float a = seed;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

void main()
{
    vec2 uv = isf_FragNormCoord.xy;
    gl_FragColor = vec4(random(uv));
}
