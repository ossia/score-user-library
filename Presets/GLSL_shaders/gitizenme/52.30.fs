/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/NtSXRW by ChaosOfZen.",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                -0.25,
                0.30
            ],
            "LABEL": "position",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                -1,
                -1
            ],
            "NAME": "position",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": 4,
            "LABEL": "scale",
            "MAX": 4.8,
            "MIN": 3,
            "NAME": "scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "rotate",
            "MAX": 3.1415,
            "MIN": -3.1415,
            "NAME": "rotate",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                1,
                0.39215686274509803,
                0.09803921568627451,
                1
            ],
            "LABEL": "materialColor",
            "NAME": "materialColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.1,
                0.3,
                0.9,
                1
            ],
            "LABEL": "crackColor",
            "NAME": "crackColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.3,
                0.3,
                0.3,
                1
            ],
            "LABEL": "backgroundColor",
            "NAME": "backgroundColor",
            "TYPE": "color"
        }
    ],
    "ISFVSN": "2"
}
*/



#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .001

#define S(a, b, t) smoothstep(a, b, t)

mat2 Rotate(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

mat2 Scale(vec2 scale){
    return mat2(scale.x,0.0,
                0.0,scale.y);
}


float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdBox(vec3 p, vec3 s) {
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
}

float sdGyroid(vec3 p, float scale, float thickness, float bias) {
	p *= scale;
    return abs(dot(sin(p), cos(p.zxy))-bias)/scale-thickness;
}

vec3 Transform(vec3 p) {
    p.xy *= Rotate(p.z*.15);
    p.y -= .4;
    return p;
}

float GetDist(vec3 p) {
    p = Transform(p);

    // float sphere1 = sdSphere(vec3(p.x+0.5, p.y, p.z), sin(TIME * 1.25) + 2.);
    // float sphere2 = sdSphere(vec3(p.x-4.5, p.y, p.z), sin(TIME * 1.75) + 2.);
    // float sphere3 = sdSphere(vec3(p.x-4.5, p.y, p.z), sin(TIME * 1.25) + 2.);
    // float sphere4 = sdSphere(vec3(p.x-1.5, p.y, p.z), sin(TIME * 1.25) + 2.);
    // float sphere5 = sdSphere(vec3(p.x+2.5, p.y, p.z), sin(TIME * 0.25) + 2.);
    // float sphere6 = sdSphere(vec3(p.x-4.5, p.y, p.z), sin(TIME * 0.5) + 2.);
    float sphere1 = sdSphere(vec3(p.x+0.5, p.y, p.z), 2.);
    float sphere2 = sdSphere(vec3(p.x-4.5, p.y, p.z), 2.);
    float sphere3 = sdSphere(vec3(p.x-4.5, p.y, p.z), 2.);
    float sphere4 = sdSphere(vec3(p.x-1.5, p.y, p.z), 2.);
    float sphere5 = sdSphere(vec3(p.x+2.5, p.y, p.z), 2.);
    float sphere6 = sdSphere(vec3(p.x-4.5, p.y, p.z), 2.);

    sphere1 = min(sphere1, -sphere2);
    sphere1 = min(sphere2, -sphere3);
    sphere1 = min(sphere3, -sphere4);
    sphere1 = min(sphere4, -sphere6);

    // sphere1 -= sphere2*.8;
    // sphere1 -= sphere3*.6;
    // sphere1 -= sphere4*.4;
    // sphere1 -= sphere5*.2;
    // sphere1 -= sphere6*.1;

    float d = sphere1;


    // float box1 = sdBox(p, vec3(1));
    // float box2 = sdBox(vec3(p.x-2., p.y, p.z), vec3(0.5));
    // float box3 = sdBox(vec3(p.x-4., p.y, p.z), vec3(1));
    // float box4 = sdBox(vec3(p.x-6., p.y, p.z), vec3(1.5));
    // float box5 = sdBox(vec3(p.x+2., p.y, p.z), vec3(1));
    // float box6 = sdBox(vec3(p.x-4., p.y, p.z), vec3(0.5));

    // box1 -= box2*.8;
    // box1 -= box3*.6;
    // box1 -= box4*.4;
    // box1 -= box5*.2;
    // box1 -= box6*.1;

    // float d = box1*.8;
   	
   	// float g1 = sdGyroid(p, 5.23, .03, 1.4);
    // float g2 = sdGyroid(p, 10.76, .03, .3);
    // float g3 = sdGyroid(p, 20.76, .03, .3);
    // float g4 = sdGyroid(p, 35.76, .03, .3);
    // float g5 = sdGyroid(p, 60.76, .03, .3);
    // float g6 = sdGyroid(p, 110.76, .03, .3);
    // //float g = min(g1, g2); // union
    // //float g = max(g1, -g2); // subtraction
    // g1 -= g2*.4;
    // g1 -= g3*.3;
    // g1 += g4*.2;
    // g1 += g5*.2;
    // g1 += g6*.3;
    
    // float d = g1*.8;//max(box, g1*.8);



    return d;
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
    vec2 e = vec2(.02, 0);
    
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
        c = p+f*z,
        i = c + uv.x*r + uv.y*u,
        d = normalize(i-p);
    return d;
}

vec3 Background(vec3 rd) {
	vec3 color = vec3(0);
    float t = TIME;
    
    float y = rd.y *.5 + .5;
    
    color += (1. - y) * materialColor.rgb * 2.;
    
    float a = atan(rd.x, rd.z);
    float flames = sin(a * 10. + t) * sin(a * 7. - t) * sin(a * 6.);
    flames *= S(.8, .5, y);
    color += flames;
    color = max(color, 0.);
    color += S(.5, .0, y);
    return color;
}

vec3 Scene(vec2 uv) {
    float t = TIME;
    vec3 color = vec3(0);

    uv.xy *= Rotate(rotate);
    uv.xy *= Scale(vec2(4.8 - scale));
    uv += sin(uv * 20. + t) * .04;
    
    vec3 ro = vec3(0, 0, -.03);
    ro.yz *= Rotate(-position.y*3.14+1.);
    ro.xz *= Rotate(-position.x*6.2831);
    
    vec3 lookat = vec3(0,0,0);
    vec3 rd = GetRayDir(uv, ro, lookat, .8);
    float d = RayMarch(ro, rd);

    if(d<MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = GetNormal(p);

        float height = p.y;

        p = Transform(p);

        float dif = n.y *.5 + .5;
        color += dif * dif;  

        float g2 = sdGyroid(p, 10.76, .03, .3);
        color *= S(-.5, .5, g2);	// blackening

        float crackWidth = -.02 + S(0., -.5, n.y) * .04;
        float cracks = S(crackWidth, -.03, g2);
        float g3 = sdGyroid(p + t * .1, 5.76, .03, .0);
        float g4 = sdGyroid(p - t * .05, 4.76, .03, .0);

        cracks *= g3 * g4 *20. + .2 * S(.2, .0, n.y);

        color += cracks * crackColor.rgb * 3.;
        float g5 = sdGyroid(p - vec3(0,t,0), 3.76, .03, .0);

        color += g5 * materialColor.rgb;

        color += S(-0., -5., height) * crackColor.rgb;
    }
    else {
        color = vec3(backgroundColor);
    }

    color = mix(color, Background(rd), S(0.1, 0.9, d));

    color *= 1.-dot(uv,uv);

    return color;
}

void main() {
    vec2 uv = (gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;
    vec3 sceneColor = vec3(0.0);    
    
    sceneColor = Scene(uv);

    gl_FragColor = vec4(sceneColor,1.0);
}
