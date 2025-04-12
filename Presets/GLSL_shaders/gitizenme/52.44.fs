/*{
    "CATEGORIES": [
        "Bezier",
        "Particle"
    ],
    "DESCRIPTION": "Particle rotation fun",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": 0.5,
            "LABEL": "scale",
            "MAX": 1,
            "MIN": 0,
            "NAME": "scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.25,
            "LABEL": "speed",
            "MAX": 1,
            "MIN": 0,
            "NAME": "speed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 20,
            "LABEL": "intensity",
            "MAX": 100,
            "MIN": 0,
            "NAME": "intensity",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "length",
            "MAX": 1,
            "MIN": 0,
            "NAME": "length",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.02,
            "LABEL": "radius",
            "MAX": 0.1,
            "MIN": 0,
            "NAME": "radius",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.125,
            "LABEL": "fading",
            "MAX": 0,
            "MIN": 0.25,
            "NAME": "fading",
            "TYPE": "float"
        },
        {
            "DEFAULT": 4,
            "LABEL": "glow",
            "MAX": 0,
            "MIN": 10,
            "NAME": "glow",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0.32941176470588235,
                0.17254901960784313,
                0.47058823529411764,
                1
            ],
            "LABEL": "color",
            "NAME": "color",
            "TYPE": "color"
        }
    ],
    "ISFVSN": "2"
}
*/

#define SCALE scale // = 0.5;
#define SPEED speed // = 0.25;
#define INTENSITY intensity // = 20.0;
#define LENGTH length // = 0.5;
#define RADIUS radius // = 0.020;
#define FADING fading // = 0.125;
#define GLOW glow // = 4.0;

#define M_2_PI 6.28318530

float Hash21(vec2 p) {
    p = fract(p*vec2(123.34, 456.21));
    p += dot(p, p+45.32);
    return fract(p.x*p.y);
}

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

// optimized 2d version of https://www.shadertoy.com/view/ldj3Wh
vec2 sdBezier(vec2 pos, vec2 A, vec2 B, vec2 C)
{    
    vec2 a = B - A;
    vec2 b = A - 2.0*B + C;
    vec2 c = a * 2.0;
    vec2 d = A - pos;

    float kk = 1.0 / dot(b,b);
    float kx = kk * dot(a,b);
    float ky = kk * (2.0*dot(a,a)+dot(d,b)) / 3.0;
    float kz = kk * dot(d,a);      

    vec2 res;

    float p = ky - kx*kx;
    float p3 = p*p*p;
    float q = kx*(2.0*kx*kx - 3.0*ky) + kz;
    float h = q*q + 4.0*p3;

    h = sqrt(h);
    vec2 x = (vec2(h, -h) - q) / 2.0;
    vec2 uv = sign(x)*pow(abs(x), vec2(1.0/3.0));
    float t = clamp(uv.x+uv.y-kx, 0.0, 1.0);

    return vec2(length(d+(c+b*t)*t),t);
}

vec2 circleR(float t){
    float x = SCALE * sin(t * TIME * SPEED) + cos(t * TIME * SPEED);
    float y = SCALE * cos(t * TIME * SPEED) + sin(t * TIME * SPEED);
    return vec2(x, y);
}

vec2 wave(float t){
    float x = SCALE * sin(t) * cos(t);
    float y = SCALE * cos(t) * tan(t);
    vec2 rXY = vec2(x, y);
    rXY *= rotate2d(sin(TIME * SPEED) + cos(TIME * SPEED));
    return rXY;
}


vec2 circle(float t){
    float x = SCALE * sin(t);
    float y = SCALE * cos(t);
    vec2 rXY = vec2(x, y);
    rXY *= rotate2d(sin(TIME));
    return rXY;
}

vec2 leminiscate(float t){
    float x = (SCALE * (cos(t) / (1.0 + sin(t) * sin(t))));
    float y = (SCALE * (sin(t) * cos(t) / (1.0 + sin(t) * sin(t))));
    vec2 rXY = vec2(x, y);
    rXY *= rotate2d(t);
    return rXY;
}

float mapInfinity(vec2 pos, float sp){
    float t = fract(-SPEED * TIME * sp);
    float dl = LENGTH / INTENSITY;
    vec2 p1 = leminiscate(t * M_2_PI);
    vec2 p2 = leminiscate((dl + t) * M_2_PI);
    vec2 c = (p1 + p2) / 2.0;
    float d = 1e9;
    
    for(float i = 2.0; i < INTENSITY; i++){
        p1 = p2;
        p2 = leminiscate((i * dl + t) * M_2_PI);
        vec2 c_prev = c;
        c = (p1 + p2) / 2.;
        pos += abs(Hash21(vec2(1., 2.)));
        vec2 f = sdBezier(pos, c_prev, p1, c);
        d = min(d, f.x + FADING * (f.y + i) / INTENSITY);
    }
    return d;
}

float mapWave(vec2 pos, float sp){
    float t = fract(-SPEED * TIME * sp);
    float dl = LENGTH / INTENSITY;
    vec2 p1 = wave(t * M_2_PI);
    vec2 p2 = wave((dl + t) * M_2_PI);
    vec2 c = (p1 + p2) / 2.0;
    float d = 1e9;

    for(float i = 2.0; i < INTENSITY; i++){
        p1 = p2;
        float r = (i * dl + t) * M_2_PI;
        p2 = wave(r);
        vec2 c_prev = c;
        c = (p1 + p2) / 2.;
        pos += abs(Hash21(vec2(1., 2.)));
        vec2 f = sdBezier(pos, c_prev, p1, c);
        d = min(d, f.x + FADING * (f.y + i) / INTENSITY);
    }
    return d;
}

float mapCircle(vec2 pos, float sp){
    float t = fract(-SPEED * TIME * sp);
    float dl = LENGTH / INTENSITY;
    vec2 p1 = circle(t * M_2_PI);
    vec2 p2 = circle((dl + t) * M_2_PI);
    vec2 c = (p1 + p2) / 2.0;
    float d = 1e9;

    for(float i = 2.0; i < INTENSITY; i++){
        p1 = p2;
        float r = (i * dl + t) * M_2_PI;
        p2 = circle(r);
        vec2 c_prev = c;
        c = (p1 + p2) / 2.;
        pos += abs(Hash21(vec2(1., 2.)));
        vec2 f = sdBezier(pos, c_prev, p1, c);
        d = min(d, f.x + FADING * (f.y + i) / INTENSITY);
    }
    return d;
}

float square(float s) { return s * s; }
vec3 square(vec3 s) { return s * s; }


vec3 neonGradient(float t) {
	return clamp(vec3(t * 1.3 + 0.1, square(abs(0.43 - t) * 1.7), (1.0 - t) * 1.7), 0.0, 1.0);
}

void main() {
    vec2 uv = (2. * gl_FragCoord.xy - RENDERSIZE.xy) / RENDERSIZE.y;
	
	float d1Rand = Hash21(vec2(0, 1));
    vec2 d1Pos = uv.yx;
    d1Pos *= rotate2d(sin(TIME * 2.) + 4. + cos(TIME * 0.25) + d1Rand );
    float dist1 = mapWave(d1Pos * vec2(1.0, 0.66), 1.);
    
	float d2Rand = Hash21(vec2(0, 1));
    vec2 d2Pos = uv.yx;
    d2Pos *= rotate2d(sin(TIME * 2.) + 4. + sin(TIME * 0.25) + d2Rand );
    float dist2 = mapInfinity(d2Pos * vec2(1.0, 2.0), 2.);

	float d3Rand = Hash21(vec2(0, 1));
    vec2 d3Pos = uv.xy * vec2(1.0, 0.66);
    d3Pos *= rotate2d(sin(TIME) + cos(TIME) + cos(uv.x) * sin(uv.y) + d3Rand);
	float dist3 = mapCircle(d3Pos, 4.);
    
    vec3 colB = color.rgb;
    vec3 col1 = neonGradient(fract(dist1 + cos(TIME * d1Rand))) * pow(RADIUS/dist1, GLOW);
	vec3 col2 = neonGradient(fract(dist2 + sin(TIME * d2Rand))) * pow(RADIUS/dist2, GLOW);
	vec3 col3 = neonGradient(fract(dist3 - cos(TIME * d3Rand))) * pow(RADIUS/dist3, GLOW);
	
	vec3 colF = (col1 + col2 + col3) * (1. * GLOW);
	// vec3 colF = (col1) * (2. * GLOW);
    vec3 col = colF;

	vec2 vUV = isf_FragNormCoord;
	vUV *=  1.0 - vUV.yx;
	float vig = vUV.x * vUV.y * 100.0; // multiply with sth for intensity
	vig = pow(vig, 0.35); // change pow for modifying the extend of the  vignette
	colB *= vig;
    
    col = mix(colF, colB, 0.5);
    
    gl_FragColor = vec4(col, 1.0);
}
