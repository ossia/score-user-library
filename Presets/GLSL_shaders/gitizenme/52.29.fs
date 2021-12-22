/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/7lXXWj by ChaosOfZen.  Just experiment",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": 1,
            "LABEL": "M1",
            "MAX": 10,
            "MIN": 0.01,
            "NAME": "M1",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.9,
            "LABEL": "M2",
            "MAX": 10,
            "MIN": 0.01,
            "NAME": "M2",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "V1",
            "MAX": 10,
            "MIN": 0.01,
            "NAME": "V1",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.9,
            "LABEL": "V2",
            "MAX": 10,
            "MIN": 0.01,
            "NAME": "V2",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "R1",
            "MAX": 10,
            "MIN": 0.01,
            "NAME": "R1",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "R2",
            "MAX": 10,
            "MIN": 0.01,
            "NAME": "R2",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "scaleFactor",
            "MAX": 10,
            "MIN": 0.1,
            "NAME": "scaleFactor",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.095,
            "LABEL": "burn",
            "MAX": 1,
            "MIN": 0,
            "NAME": "burn",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.095,
            "LABEL": "blend",
            "MAX": 1,
            "MIN": 0,
            "NAME": "blend",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0.3333333333333333,
                0.6666666666666666,
                1,
                1
            ],
            "LABEL": "color",
            "NAME": "color",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0,
                0,
                0,
                1
            ],
            "LABEL": "background",
            "NAME": "background",
            "TYPE": "color"
        }
    ],
    "ISFVSN": "2"
}
*/


#define MAX_ITER 250

vec2 rotate(vec2 uv, float radians)
{
  mat2 rot = mat2(cos(radians), -sin(radians),
                   sin(radians), cos(radians));
 
  return uv.xy * rot;
}

vec2 scale(vec2 uv, vec2 scale)
{
    mat2 s = mat2(scale.x, 0.0, 0.0, scale.y);
    return -(uv.xy * s);
}


float bpm = 138.; // beats per minute
float bbpm = 4.;  // beats per measure


void main() {
    vec2 uv = ( gl_FragCoord.xy - .5 * RENDERSIZE.xy ) / RENDERSIZE.y;

    float spm = (bbpm * 60. / bpm) / 4.; // seconds per measure

    float timeScale = TIME / spm;
    uv = rotate(uv, timeScale / 4.);   
    uv = scale(uv, vec2(scaleFactor, scaleFactor));

    vec2 z = vec2(0.0, 0.0);
	float p = 0.0;
	float dist = 0.0;

	float x1 = tan(timeScale * V1) + R1;
	float y1 = sin(timeScale * V1) + R1; 
	float x2 = tan(timeScale / V2) + R2;
	float y2 = sin(timeScale / V2) + R2;


	for (int i=0; i < MAX_ITER; ++i)
	{
		z *= 2.0;
		z = mat2(z, -z.y, z.x) * z + uv;
		p = M1 / sqrt((z.x - x1) * (z.x - x1) + (z.y - y1) * (z.y - y1)) + M2 / sqrt((z.x - x2) * (z.x - x2) + (z.y - y2) * (z.y - y2));
		dist = max(dist, p);
	}

	dist *= burn;

    vec4 fColor = background;
    vec4 sColor = color;
    
    fColor += vec4(dist * sColor.r, dist * sColor.g, dist * sColor.b, 1.0);
    fColor.rgb = clamp(vec3(0.01), vec3(0.85), fColor.rgb);

	gl_FragColor = fColor;
}
