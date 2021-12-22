/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/7tl3z4 by ChaosOfZen.  A few extra primitive functions.",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": 25,
            "LABEL": "brightness",
            "MAX": 100,
            "MIN": 0,
            "NAME": "brightness",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.8,
            "LABEL": "gamma",
            "MAX": 1,
            "MIN": 0.01,
            "NAME": "gamma",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "cameraX",
            "MAX": 20,
            "MIN": -20,
            "NAME": "cameraX",
            "TYPE": "float"
        },
        {
            "DEFAULT": -8,
            "LABEL": "cameraZ",
            "MAX": 20,
            "MIN": -20,
            "NAME": "cameraZ",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0.1,
                0.35,
                0.8,
                1
            ],
            "LABEL": "baseColor",
            "MAX": [
                1,
                1,
                1,
                1
            ],
            "MIN": [
                0,
                0,
                0,
                0
            ],
            "NAME": "baseColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.1,
                0.1,
                0.1,
                1
            ],
            "LABEL": "shadeColor",
            "MAX": [
                1,
                1,
                1,
                1
            ],
            "MIN": [
                0,
                0,
                0,
                0
            ],
            "NAME": "shadeColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": 0,
            "LABEL": "lightPosX",
            "MAX": 6.28,
            "MIN": -6.28,
            "NAME": "lightPosX",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "lightPosY",
            "MAX": 6.28,
            "MIN": -6.28,
            "NAME": "lightPosY",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "lightPosZ",
            "MAX": 6.28,
            "MIN": -6.28,
            "NAME": "lightPosZ",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd1y",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd1y",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3,
            "LABEL": "sd1z",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd1z",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd1r",
            "MAX": 5,
            "MIN": 0,
            "NAME": "sd1r",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd2y",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd2y",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3,
            "LABEL": "sd2z",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd2z",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd2r",
            "MAX": 5,
            "MIN": 0,
            "NAME": "sd2r",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd3y",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd3y",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3,
            "LABEL": "sd3z",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd3z",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd3r",
            "MAX": 5,
            "MIN": 0,
            "NAME": "sd3r",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd4y",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd4y",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3,
            "LABEL": "sd4z",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd4z",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd4r",
            "MAX": 5,
            "MIN": 0,
            "NAME": "sd4r",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd5y",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd5y",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3,
            "LABEL": "sd5z",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd5z",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd5r",
            "MAX": 5,
            "MIN": 0,
            "NAME": "sd5r",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd6y",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd6y",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3,
            "LABEL": "sd6z",
            "MAX": 5,
            "MIN": 1,
            "NAME": "sd6z",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "sd6r",
            "MAX": 5,
            "MIN": 0,
            "NAME": "sd6r",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/

float sd1x = -0.5;
float sd2x = 1.6;
float sd3x = 3.7;
float sd4x = -2.6;
float sd5x = -4.7;
float sd6x = -6.9;
float offset = 1.5;
//
// Based on:
// "ShaderToy Tutorial - Ray Marching Primitives" 
// by Martijn Steinrucken aka BigWings/CountFrolic - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
// This shader is part of a tutorial on YouTube
// https://youtu.be/Ff0jJyyiVyw

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .001

float sdSphere(vec3 p, float r) {
    float sphereDist = length(p)-r;
    return sphereDist;
}

float GetDist(vec3 p) {
    float planeDist = p.y+0.;
   
    float sd1 = sdSphere(p-vec3(sd1x, sd1y, sd1z), sd1r);
    float sd2 = sdSphere(p-vec3(sd2x+offset, sd2y, sd2z), sd2r);
    float sd3 = sdSphere(p-vec3(sd3x+offset, sd3y, sd3z), sd3r);
    float sd4 = sdSphere(p-vec3(sd4x-offset, sd4y, sd4z), sd4r);
    float sd5 = sdSphere(p-vec3(sd5x-offset, sd5y, sd5z), sd5r);
    float sd6 = sdSphere(p-vec3(sd6x-offset, sd6y, sd6z), sd6r);

    float d = 0.;
    d = min(sd1, planeDist);
    d = min(d, sd2); 
    d = min(d, sd3); 
    d = min(d, sd4); 
    d = min(d, sd5); 
    d = min(d, sd6); 
    
    return d;
}

float RayMarch(vec3 ro, vec3 rd) {
	float dO=0.;
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p = ro + rd*dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO>MAX_DIST || dS<SURF_DIST) break;
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

float GetLight(vec3 p) {
    vec3 lightPos = vec3(0, 5, -1);
    lightPos.xz += vec2(sin(TIME), cos(TIME))*180./60.;
    lightPos.x += lightPosX;
    lightPos.y += lightPosY;
    lightPos.z += lightPosZ;
    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p);
    
    float dif = clamp(dot(n, l), 0., 1.);
    float d = RayMarch(p+n*SURF_DIST*2.0, l);
    if(d<length(lightPos-p)) dif *= .1;
    
    return dif;
}

void main() {
    vec2 uv = (gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;
    vec3 col = vec3(baseColor.rgb);
    
    vec3 ro = vec3(cameraX, 4, cameraZ);
    vec3 rd = normalize(vec3(uv.x-.15, uv.y-.2, 1));
    float d = RayMarch(ro, rd);
    
    vec3 p = ro + rd * d;
    
    float dif = GetLight(p);
    col *= vec3(dif*brightness);
    
    col.rgb *= shadeColor.rgb;
    
    col = pow(col, vec3(gamma));	// gamma correction
    
    gl_FragColor = vec4(col, 1.0);
}
