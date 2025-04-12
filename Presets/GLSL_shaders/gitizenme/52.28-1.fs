/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/MdX3zr by XT95.  Simple flame in distance field.",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                1,
                0.5,
                0.1,
                1
            ],
            "LABEL": "Flame Gradient Start",
            "NAME": "flameGradS",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.1,
                0.5,
                1,
                1
            ],
            "LABEL": "Flame Gradient End",
            "NAME": "flameGradE",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0,
                0,
                0,
                1
            ],
            "LABEL": "Background Color",
            "NAME": "bgColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": 1,
            "LABEL": "flame1Scale",
            "MAX": 4,
            "MIN": 0,
            "NAME": "flame1Scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "flame2Scale",
            "MAX": 4,
            "MIN": 0,
            "NAME": "flame2Scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "flame3Scale",
            "MAX": 4,
            "MIN": 0,
            "NAME": "flame3Scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "flame1X",
            "MAX": 4,
            "MIN": 0,
            "NAME": "flame1X",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "flame2X",
            "MAX": 4,
            "MIN": 0,
            "NAME": "flame2X",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "flame3X",
            "MAX": 4,
            "MIN": 0,
            "NAME": "flame3X",
            "TYPE": "float"
        },
		{
            "DEFAULT": 2.5,
            "LABEL": "Intensity",
            "MAX": 10,
            "MIN": 2.5,
            "NAME": "intensity",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1.5,
            "LABEL": "Darkness",
            "MAX": 3,
            "MIN": 1.5,
            "NAME": "darkness",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/

 mat2 Rotate(float a) {
    float s=sin(a); 
    float c=cos(a);
    return mat2(c,-s,s,c);
}

float noise(vec3 p) //Thx to Las^Mercury
{
	vec3 i = floor(p);
	vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
	vec3 f = cos((p - i) * acos(-1.)) * (-.5) + .5;
	a = mix(sin(cos(a) * a), sin(cos(1. + a)*(1. + a)), f.x);
	a.xy = mix(a.xz, a.yw, f.y);
	return mix(a.x, a.y, f.z);
}

float sphere(vec3 p, vec4 spr)
{
	return length(spr.xyz - p) - spr.w;
}

float flame(vec3 p)
{


	float bpm = 58.;
    float bbpm = 4.;  // beats per measure
    float spm = (bbpm*60./(bpm))/4.; // seconds per measure


	float planeDist = dot(p, vec3(0, 0, 1. - darkness)) + intensity;
	float spmTime = TIME/spm;
	float sNoise = noise(p * 3.) * .5;

	float s1 = sphere(p * vec3(flame1X, .5, 1), vec4(0, -1. * flame1Scale, 0, flame1Scale));
	s1 += ( noise( p + vec3(.0, spmTime, 0)) + sNoise ) * .25 * (p.y);

	float s2 = sphere(p * vec3(flame2X, .5, 1), vec4(-3., -1. * flame2Scale, 0, flame2Scale));
	s2 += ( noise( p + vec3(.0, spmTime, 0)) + sNoise ) * .25 * (p.y);

	float s3 = sphere(p * vec3(flame3X, .5, 1), vec4(3., -1. * flame3Scale, .0, flame3Scale));
	s3 += ( noise( p + vec3(.0, spmTime, 0)) + sNoise ) * .25 * (p.y);


	float d = 0.;
	d = min(s1, planeDist);
	d = min(d, s1);
    d = min(d, s2);
    d = min(d, s3);

	return d;
}

float scene(vec3 p)
{
	return min(100.-length(p) , abs(flame(p)) );
}

vec4 raymarch(vec3 org, vec3 dir)
{
	float d = 0.0, glow = 0.0, eps = 0.02;
	vec3  p = org;
	bool glowed = false;
	
	for(int i=0; i<64; i++)
	{
		d = scene(p) + eps;
		p += d * dir;
		if( d > eps )
		{
			if(flame(p) < .001)
				glowed = true;
			if(glowed)
       			glow = float(i) / 64.;
		}
	}
	return vec4(p, glow);
}

void main() {

	vec2 v = -1.0 + 2.0 * isf_FragNormCoord;
	v.x *= RENDERSIZE.x/RENDERSIZE.y;
	
	vec3 org = vec3(0., -2., 4.);
	vec3 dir = normalize(vec3(v.x * 1.6, -v.y, -1.5));
	
	vec4 p = raymarch(org, dir);
	float glow = p.w;
	
	vec4 col = mix(vec4(flameGradS.rgb, 1.0), vec4(flameGradE.rgb, 1.0), p.y * .04 + .4);
	
	gl_FragColor = mix(vec4(vec3(bgColor.rgb), 0), col, pow(glow * 2., 4.));
}

