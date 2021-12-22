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
            "MAX": 6.28,
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

vec2 circle(float t){
    float x = SCALE * sin(t);
    float y = SCALE * cos(t);
    return vec2(x, y);
}

vec2 leminiscate(float t){
    float x = (SCALE * (cos(t) / (1.0 + sin(t) * sin(t))));
    float y = (SCALE * (sin(t) * cos(t) / (1.0 + sin(t) * sin(t))));
    return vec2(x, y);
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
        p2 = circle((i * dl + t) * M_2_PI);
        vec2 c_prev = c;
        c = (p1 + p2) / 2.;
        vec2 f = sdBezier(pos, c_prev, p1, c);
        d = min(d, f.x + FADING * (f.y + i) / INTENSITY);
    }
    return d;
}

void main() {
    vec2 uv = (2. * gl_FragCoord.xy - RENDERSIZE.xy) / RENDERSIZE.y;
	
    float dist1 = mapCircle(uv.yx * vec2(1.0, 0.66), 1.);
	float dist2 = mapInfinity(uv.xy * vec2(0.66, 1.0), 2.);
	float dist3 = mapCircle(uv.xy * vec2(1.0, 0.88), 3.);
    
    vec3 col1 = vec3(1.0, 0.55, 0.25) * pow(RADIUS/dist1, GLOW);
	vec3 col2 = vec3(0.55, 1.00, 0.25) * pow(RADIUS/dist2, GLOW);
	vec3 col3 = vec3(0.25, 0.55, 1.00) * pow(RADIUS/dist3, GLOW);
	
	vec3 col = (col1 + col2 + col3) * (2. * GLOW);
    
    gl_FragColor = vec4(col, 1.0);
}
