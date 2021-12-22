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
                -231.55,
                -124.32
            ],
            "MAX": [
                360,
                360
            ],
            "MIN": [
                -360,
                -360
            ],
            "NAME": "pos",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.5725490196078431,
                0.3686274509803922,
                0,
                1
            ],
            "NAME": "bgColorA",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0,
                0,
                1,
                1
            ],
            "NAME": "bgColorB",
            "TYPE": "color"
        },
        {
            "DEFAULT": 30,
            "MAX": 100,
            "MIN": 1,
            "NAME": "specFactor",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                1,
                0,
                0,
                1
            ],
            "NAME": "shapeColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": 0.5,
            "MAX": 2,
            "MIN": 0,
            "NAME": "zoom",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/

// vec3 bgColorA = vec3(.2, .1, .1);
// vec3 bgColorB = vec3(.2, .5, 1);

// "Torus Knot Tutorial" 
// by Martijn Steinrucken aka BigWings/CountFrolic - 2020
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// 
// This shader is the end result of a tutorial on YouTube
// https://youtu.be/2dzJZx0yngg

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .001

#define S smoothstep

mat2 Rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float Hash21(vec2 p) {
    p = fract(p*vec2(123.34,233.53));
    p += dot(p, p+23.234);
    return fract(p.x*p.y);
}

float sdBox(vec3 p, vec3 s) {
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
}

float sdBox2d(vec2 p, vec2 s) {
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, p.y), 0.);
}

float opU( float d1, float d2 )
{
    return min( d1, d2 );
}

float sminCubic( float a, float b, float k )
{
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}

int bpm = 60;
float bbpm = 1. / 4.;  // beats per measure
float spm = (bbpm * (float(bpm) / 60.)); // seconds per measure



float GetDist(vec3 p) {
    float r1 = 1.7, r2=.3;
    vec2 cp = vec2(length(p.xz)-r1, p.y);
    float a = atan(p.x, p.z); // polar angle between -pi and pi
    cp *= Rot(a * 1. + TIME * spm);
    cp.y = abs(cp.y)-.4;

   	// d = length(cp) - .3*(sin(TIME+10.*r2)*.5+.5)-.19;


    float d = 0.;
    float box1 = sdBox2d(cp, vec2(.1, .3 * (sin(2. * a) * .5 + .5)) + .5 * (cos(TIME * 4. * spm) * .5 + .5));
    d = box1;
    float box2 = sdBox2d(cp, vec2(.2, .3 * (sin(2. * a) * .5 + .5)) + .5 * (cos(TIME * 4. * spm) * .5 + .5));
   	d = sminCubic(d, box2, 1.);
    float box3 = sdBox2d(cp, vec2(.8, .3 * (sin(2. * a) * .5 + .5)) + .5 * (cos(TIME * 4. * spm) * .5 + .5));
   	d = sminCubic(d, box3, 1.);
    float box4 = sdBox2d(cp, vec2(.5, .3 * (sin(2. * a) * .5 + .5)) + .5 * (cos(TIME * 4. * spm) * .5 + .5));
   	d = sminCubic(d, box4, 1.);
    
    return d; // * .8;
}

float RayMarch(vec3 ro, vec3 rd) {
	float dO=0.;
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p = ro + rd*dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
    }
    
    return dO;
}

vec3 GetNormal(vec3 p) {
	float d = GetDist(p);
    vec2 e = vec2(.001, 0);
    
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));
    
    return normalize(n);
}

vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z) {
    vec3 f = normalize(l-p),
        r = normalize(cross(vec3(0,1,0), f)),
        u = cross(f,r),
        c = f*z,
        i = c + uv.x*r + uv.y*u,
        d = normalize(i);
    return d;
}


vec3 Bg(vec3 rd) {
	float k = rd.y*.5+.5;
    
    vec3 col = mix(bgColorA.rgb, bgColorB.rgb, k);
    return col;
}

void main() {

    vec2 uv = (gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;
	vec2 m = pos.xy/RENDERSIZE.xy;
    
    vec3 col = vec3(0);
    
    vec3 ro = vec3(m.x, m.y, 6);
    ro.yz *= Rot(m.y*6.2831);
    ro.xz *= Rot(m.x*6.2831);
    
    vec3 rd = GetRayDir(uv, ro, vec3(0), zoom);
	
    col += Bg(rd);
    
    float d = RayMarch(ro, rd);
    
    if(d<MAX_DIST) {
    	vec3 p = ro + rd * d;
    	vec3 n = GetNormal(p);
        vec3 r = reflect(rd, n);
        
        float spec = pow(max(0., r.y), specFactor);
        float dif = dot(n, normalize(Bg(r).rgb * 30.))*.5+.5;
    	col = mix(Bg(r), vec3(dif) * shapeColor.rgb, clamp(0.2, 0.9, sin(TIME * 0.25))) + spec;
    }
    
    col = pow(col, vec3(.4545));	// gamma correction
    
    gl_FragColor = vec4(col,1.0);
}
