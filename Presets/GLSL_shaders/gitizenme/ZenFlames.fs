/*{
    "CATEGORIES": [
        "generator",
        "flame",
        "color"
    ],
    "CREDIT": "by ChaosofZen",
    "DESCRIPTION": "",
    "INPUTS": [
        {
            "DEFAULT": 5,
            "MAX": 20,
            "MIN": -20,
            "NAME": "zoom",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "MAX": 10.25,
            "MIN": -10.25,
            "NAME": "rotationSpeed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 5,
            "MAX": 12,
            "MIN": 4,
            "NAME": "loops",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.04,
            "MAX": 0.075,
            "MIN": 0.025,
            "NAME": "intensity",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3.3,
            "MAX": 5,
            "MIN": 2,
            "NAME": "brightness",
            "TYPE": "float"
        },
        {
            "DEFAULT": 2,
            "MAX": 5,
            "MIN": -5,
            "NAME": "rate",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.8,
            "LABEL": "red",
            "MAX": 1,
            "MIN": 0,
            "NAME": "red",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "green",
            "MAX": 1,
            "MIN": 0,
            "NAME": "green",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.1,
            "LABEL": "blue",
            "MAX": 1,
            "MIN": 0,
            "NAME": "blue",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "alpha",
            "MAX": 1,
            "MIN": 0,
            "NAME": "alpha",
            "TYPE": "float"
        },
        {
        "NAME": "shift",
        "TYPE": "point2D",
        "DEFAULT": [
            20,
            20
        ],
        "MAX": [
            30,
            30
        ],
        "MIN": [
            10,
            10
        ]
        }
    ],
    "ISFVSN": "2"
}
*/

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

vec2 rotate2d(vec2 uv, float a){
    return vec2(uv.x * cos(a) - uv.y * sin(a),
                uv.y * cos(a) + uv.x * sin(a));
}

void main() 
{
    vec2 uv = ((gl_FragCoord.xy-.5 * RENDERSIZE) / RENDERSIZE.y) * zoom - shift;
	vec2 i = uv;
	float c = 1.0;
	float bc = 0.0;

	for (int n = 0; n < 16; n++)
	{
		int bpc = int(floor(loops*2.5));
        bpc -= n;
        if (bpc<1) break;

        uv -= vec2(0.5);
        uv = rotate2d(uv, rotationSpeed);
        uv += vec2(0.5);

        float t = -TIME * (1.5 - (2.0 / float(n+1))) *rate;
		i = uv + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(uv.x / (2.*sin(i.x+t)/intensity),uv.y / (cos(i.y+t)/intensity)));
	}
	c /= float(18.-loops);
	c = 1.5-sqrt(pow(c,brightness));
	float col = c*c*c*c;
	gl_FragColor = vec4(vec3(col * red, col * green, col * blue), alpha);

}