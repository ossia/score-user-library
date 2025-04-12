/*{
    "CATEGORIES": [
        "Chaos",
        "Symbol"
    ],
    "CREDIT": "Chaos.of.Zen",
    "DESCRIPTION": "Shader of the symbol for Chaos",
    "IMPORTED": {
    },
    "ISFVSN": "2"
}
*/

/*
        {
            "DEFAULT": 0.1,
            "LABEL": "Background Red",
            "MAX": 1,
            "MIN": 0,
            "NAME": "bgRed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.44,
            "LABEL": "Background Green",
            "MAX": 1,
            "MIN": 0,
            "NAME": "bgGreen",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.9,
            "LABEL": "Background Blue",
            "MAX": 1,
            "MIN": 0,
            "NAME": "bgBlue",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Background Alpha",
            "MAX": 1,
            "MIN": 0,
            "NAME": "bgAlpha",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.3,
            "LABEL": "Shape Red",
            "MAX": 1,
            "MIN": 0,
            "NAME": "shapeRed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.24,
            "LABEL": "Shape Green",
            "MAX": 1,
            "MIN": 0,
            "NAME": "shapeGreen",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.8,
            "LABEL": "Shape Blue",
            "MAX": 1,
            "MIN": 0,
            "NAME": "shapeBlue",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Shape Alpha",
            "MAX": 1,
            "MIN": 0,
            "NAME": "shapeAlpha",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.1,
            "LABEL": "Torus Radius Outer",
            "MAX": 1,
            "MIN": 0,
            "NAME": "torusRadiusOuter",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.1,
            "LABEL": "Torus Radius Innter",
            "MAX": 1,
            "MIN": 0,
            "NAME": "torusRadiusInner",
            "TYPE": "float"
        },
        {
            "DEFAULT": 8,
            "LABEL": "Number of Arrows",
            "MAX": 16,
            "MIN": 1,
            "NAME": "numberOfArrows",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Spin",
            "MAX": 5,
            "MIN": -5,
            "NAME": "spin",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Pivot Horizontal",
            "MAX": 5,
            "MIN": -5,
            "NAME": "pivotH",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Pivot Vertical",
            "MAX": 5,
            "MIN": -5,
            "NAME": "pivotV",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Shape Size",
            "MAX": 5,
            "MIN": 0,
            "NAME": "shapeSize",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "Arrow Length",
            "MAX": 1,
            "MIN": -0.1,
            "NAME": "arrowLength",
            "TYPE": "float"
        },
        {
            "DEFAULT": false,
            "LABEL": "Auto Rotate",
            "NAME": "autoRotate",
            "TYPE": "bool"
        }

*/

float bgRed = 0.1;
float bgGreen = 0.1;
float bgBlue = 0.1;
float bgAlpha = 1.0;
float shapeRed = 1.;
float shapeGreen = 1.;
float shapeBlue = 1.;
float shapeAlpha = 1.0;

float torusRadiusInner = 0.1;
float torusRadiusOuter = 0.1;

float numberOfArrows = 8.;
float spin = 0.;
float pivotH = 0.01;
float pivotV = 0.01;
float shapeSize = 1.5;

float arrowLength = 0.1;
bool autoRotate = false;

float seconds = 6.;
float warp = 0.12;
bool rotation = true;
float rings = 32.;
float rotationAngle = 3.14;
float rotationSpeed = 3.;

#define PI 3.14159
#define HALF_PI 1.57079632675
#define TWO_PI 2.*PI

// #define rotationAngle PI

// #define pulse true
// #define rotation true

vec2 randomNoise(vec2 uv)
{    
    uv = vec2( dot(uv,vec2(127.1,311.7)),
              dot(uv,vec2(29.5,183.3)) );
    return -1.0 + 2.0*fract(sin(uv)*43758.5453123);
}

float randomVignette(vec2 uv)
{
    return fract(sin(dot(uv.yx,vec2(14.7891,43.123)))*312991.41235);
}

float randomMovement(in float x)
{
    return fract(sin(x)*43758.5453123);
}


float vignetteNoise(vec2 uv) {
    vec2 ring = floor(uv);
    vec2 f = fract(uv);

    vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( dot( randomNoise(ring + vec2(0.0,0.0)), f - vec2(0.0,0.0) ),
                     dot( randomNoise(ring + vec2(1.0,0.0)), f - vec2(1.0,0.0) ), u.x),
                mix( dot( randomNoise(ring + vec2(0.0,1.0)), f - vec2(0.0,1.0) ),
                     dot( randomNoise(ring + vec2(1.0,1.0)), f - vec2(1.0,1.0) ), u.x), u.y);
}

mat2 rotate(float angle)
{
    return mat2( cos(angle),-sin(angle),sin(angle),cos(angle) );
}

vec2 ratio(vec2 uv)
{
    return  vec2(
            max(uv.x/uv.y,1.0),
            max(uv.y/uv.x,1.0)
            );
}

vec2 center(vec2 uv)
{
    float aspect = RENDERSIZE.x/RENDERSIZE.y;
    uv.x = uv.x * aspect - aspect * 0.5 + 0.5;
    return uv;
}

vec3 time()
{
    float period = mod(TIME,seconds);
    vec3 t = vec3(fract(TIME/seconds),period, 1.0-fract(period));
    return t;       // return fract(length),period,period phase
}

float zen(vec2 uv, vec3 t)
{
    uv = uv * 2.0 - 1.0;

    float seed = 29192.173;
    float center = length(uv-0.5) - 0.5;

    float n_scale = warp;

    float n_1 = vignetteNoise(uv + PI) * n_scale;
    float n_2 = vignetteNoise(uv+seed - PI) * n_scale;
    if(rotation) {
        float n_1 = vignetteNoise(uv + sin(PI*t.x)) * n_scale;
        float n_2 = vignetteNoise(uv+seed - sin(PI*t.x)) * n_scale;
    }

    float d = 1.0;
    for(float ring = 1.; ring <= rings; ring++)
    {
        float spread = 1.0 / ring;
        float speed = ceil(rotationSpeed*spread);
        float r = randomMovement(ring*5.0 + seed);
        float r_scalar = r * 2.0 - 1.0;

        vec2 pos = uv - vec2(0.0);

        pos *= rotate(rotationAngle);

        if(rotation) {
            pos += vec2(0.01) * rotate(TWO_PI * r_scalar + TWO_PI * t.x * speed * sign(r_scalar));
            pos *= rotate(TWO_PI * r_scalar + TWO_PI * t.x * speed * sign(r_scalar) + vignetteNoise(pos + float(ring) + TIME) );
            pos += mix(n_1,n_2,0.5+0.5*sin(TWO_PI*t.x*speed));
            pos *= rotate(TWO_PI * r_scalar + TWO_PI * t.x * speed * sign(r_scalar) + vignetteNoise(pos + float(ring) + TIME) );
        }

        float s = .45 + .126 * r;

        float a = atan(pos.y,pos.x)/PI;
        a = abs(a);
        a = smoothstep(0.0,1.0,a);

        float c = length(pos);
        c = abs(c-s);
        c -= 0.0004 + .0125 * a;

        d = min(d,c);
    }

    return d;
}


// geometry functions from iq / mercury
void drawArrows(inout vec2 p, float c) {
	float m = TWO_PI / c;
	float a = mod(atan(p.x, p.y) - m*.5, m) - m*.5;
	p = vec2(cos(a), sin(a)) * length(p*shapeSize);
}

mat2 radToDec(float a) {
	float c = cos(a), s = sin(a);
	return mat2(c, s, -s, c);
}

float box(vec3 p, vec3 b)
{
	float boxLength = 1.;
	boxLength += arrowLength;
	vec3 d = abs(p * (boxLength)) - b;
	return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float length8(vec2 p) {
	p = pow(p, vec2(8.));
	return pow(p.x + p.y, 1. / 8.);
}

float torus82(vec3 p, vec2 t)
{
	vec2 q = vec2(length(p.xz) - t.x, p.y);
	return length8(q) - t.y;
}

float cone(vec3 p, vec2 c)
{
	// c must be normalized
	float q = length(p.xy);
	return dot(c, vec2(q, p.z));
}

float clampSmooth(float a, float b, float r) {
	return clamp(.5 + .5*(b - a) / r, 0., 1.);
}

float smoothMin(float a, float b, float r) {
	float h = clampSmooth(a, b, r);
	return mix(b, a, h) - r*h*(1. - h);
}

float smoothMax(float a, float b, float r) {
	float h = clampSmooth(a, b, r);
	return mix(a, b, h) + r*h*(1. - h);
}

float de(vec3 p, vec2 uv, vec3 t) {
	if(autoRotate) {
		p.xz *= radToDec(TIME*-pivotV);
		p.zy *= radToDec(TIME*-pivotH);
		p.xy *= radToDec(TIME*-spin);
	}
	else {
		p.xz *= radToDec(-pivotV);
		p.zy *= radToDec(-pivotH);
		p.xy *= radToDec(-spin);
	}

	float d = torus82(p.yzx, vec2(torusRadiusInner, torusRadiusOuter));

    float zD = zen(uv, t);
    d = smoothMin(d, zD, .1);

	// drawArrows(p.xy, numberOfArrows);
	// d = smoothMin(d, box(p, vec3(1.3, .1, .1)), .1);

	// p.x -= 1.7;
	// p.x += arrowLength;
	// p.xy *= radToDec(-PI*.5);

	// d = smoothMin(d, max(cone(p.zxy, normalize(vec2(.4, .2))), -p.y - .4), .1);
	return d;
}

vec3 normal(in vec3 pos, vec2 uv, vec3 t)
{
	vec2 e = vec2(1., -1.)*.5773*.0005;
	return normalize(e.xyy*de(pos + e.xyy, uv, t) +
		e.yyx*de(pos + e.yyx, uv, t) +
		e.yxy*de(pos + e.yxy, uv, t) +
		e.xxx*de(pos + e.xxx, uv, t));
}

void main() {
	vec2 q = isf_FragNormCoord;
    vec2 uv = (q - .5) * RENDERSIZE.xx / RENDERSIZE.yx;
	vec3 ro = vec3(0, 0, 3.5);
	vec3 rd = normalize(vec3(uv, -1));
	vec3 p;
	float t = 0.;

    vec3 tS = time();

	for (float i = 0.; i < 1.; i += .01) {
		p = ro + rd*t;
		float d = de(p, uv, tS);
		if (d<.001 || t>100.) break;
		t += d;
	}

	vec4 pct = (vec4(uv.x, uv.y, uv.x, 1.));

	vec4 backgroundColor = vec4(bgRed, bgGreen, bgBlue, bgAlpha);
	vec4 backgroundGradient = vec4(0.,0.,0.,1.);
	// backgroundColor = mix(backgroundColor, backgroundGradient, pct);
	vec4 col = backgroundColor;

	vec4 shapeColor = vec4(shapeRed, shapeGreen, shapeBlue, shapeAlpha);
	vec4 shapeGradient = vec4(0.,0.,0.,1.);
	// shapeColor = mix(shapeColor, shapeGradient, pct);

	if (t <= 100.) {
		col = shapeColor;
	}

	float brightnessAll = 0.5;
	float brightness = 0.75;
	float edgeBrightness = 0.1;
	float centerBrightness = 16.0;
	col *= brightness + brightnessAll*pow(centerBrightness*q.x*q.y*(1.0 - q.x)*(1.0 - q.y), edgeBrightness);
	
	gl_FragColor = vec4(col);
}
