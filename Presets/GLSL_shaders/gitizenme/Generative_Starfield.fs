/*{
    "CATEGORIES": [
        "Geneative",
        "Starfield"
    ],
    "DESCRIPTION": "Attribution from https://www.shadertoy.com/view/tlyGW3 by BigWIngs.",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": 0.3,
            "LABEL": "Star Brigtness",
            "MAX": 32,
            "MIN": 0,
            "NAME": "sizeX",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.2,
            "LABEL": "Red",
            "MAX": 1,
            "MIN": 0,
            "NAME": "red",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.3,
            "LABEL": "Green",
            "MAX": 1,
            "MIN": 0,
            "NAME": "green",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.9,
            "LABEL": "Blue",
            "MAX": 1,
            "MIN": 0,
            "NAME": "blue",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Alpha",
            "MAX": 1,
            "MIN": 0,
            "NAME": "alpha",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.4545,
            "LABEL": "Gamma",
            "MAX": 10,
            "MIN": 0.1,
            "NAME": "gamma",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0,
                0
            ],
            "LABEL": "Offset",
            "MAX": [
                64000,
                48000
            ],
            "MIN": [
                -64000,
                -48000
            ],
            "NAME": "offset",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": 6,
            "LABEL": "Layers",
            "MAX": 30,
            "MIN": 1,
            "NAME": "layers",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.02,
            "LABEL": "Speed",
            "MAX": 1,
            "MIN": -1,
            "NAME": "speed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3,
            "LABEL": "Shimmer",
            "MAX": 100,
            "MIN": 0,
            "NAME": "shimmer",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Color Saturation",
            "MAX": 8,
            "MIN": 0.02,
            "NAME": "colorSat",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                1,
                1
            ],
            "LABEL": "Rotation Factor",
            "MAX": [
                100,
                100
            ],
            "MIN": [
                1,
                1
            ],
            "NAME": "rotationFactor",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.9,
                1
            ],
            "LABEL": "Flare Factor",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0.1,
                0.1
            ],
            "NAME": "flareFactor",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                20,
                0.5
            ],
            "LABEL": "Depth Factor",
            "MAX": [
                2000,
                2000
            ],
            "MIN": [
                0.01,
                0.01
            ],
            "NAME": "depthFactor",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                1,
                0.25,
                1,
                1
            ],
            "LABEL": "Color Tint Start",
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
            "NAME": "colorTintStart",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.2,
                0.2,
                0.1,
                1
            ],
            "LABEL": "Color Tint End",
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
            "NAME": "colorTintEnd",
            "TYPE": "color"
        },
        {
            "DEFAULT": true,
            "LABEL": "rotate",
            "NAME": "rotate",
            "TYPE": "bool"
        }
    ],
    "ISFVSN": "2"
}
*/


// Starfield Tutorial by Martijn Steinrucken aka BigWings - 2020
// countfrolic@gmail.com
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define PI 3.14159265359

mat2 rotate2d(float a) {
    float s=sin(a*rotationFactor.x), c=cos(a*rotationFactor.y);
    return mat2(c, -s, s, c);
}

float Star(vec2 uv, float flare) {
	float d = length(uv);
    float m = 0.05/d;
    
    float sx = 1000.;
    float rays = max(0., 1.-abs(uv.x*uv.y*sx));
    
    for(float r=4.; r<=8.; r++) {
        uv *= rotate2d(TIME*PI/(r*2.5));
        uv *= rotate2d(PI/r);
        rays = max(0., 1.-abs(uv.x*uv.y*sx));
        m += rays*(r*0.2)*flare;
    }

    m *= smoothstep(1., .2, d);
    return m;
}

float Hash21(vec2 p) {
    p = fract(p*vec2(123.34, 456.21));
    p += dot(p, p+45.32);
    return fract(p.x*p.y);
}

vec3 StarLayer(vec2 uv) {
	vec3 col = vec3(0);
	
    vec2 gv = fract(uv)-.5;
    vec2 id = floor(uv);
    
    for(int y=-1;y<=1;y++) {
    	for(int x=-1;x<=1;x++) {
            vec2 offs = vec2(x, y);
            
    		float n = Hash21(id+offs); // random between 0 and 1
            float size = fract(n*345.32);
            
    		float star = Star(gv-offs-vec2(n, fract(n*34.))+.5, smoothstep(flareFactor.x, flareFactor.y, size)*sizeX);
            
            vec3 color = sin(vec3(red, green, blue)*fract(n*2345.2)*123.2)*.5+.5;
            color = color*vec3(colorTintStart.r,colorTintStart.g,colorTintStart.b+size)+vec3(colorTintEnd.r, colorTintEnd.g, colorTintEnd.b);
            color *= colorSat;
        
            star *= sin(TIME*shimmer+n*6.2831)*.5+1.;
            col += star*size*color;
        }
    }
    return col;
}

void main() {

    vec2 uv = (gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;
    vec2 M = (-offset.xy*RENDERSIZE.xy*.5)/RENDERSIZE.y;
    
    float t = TIME*speed;
        
    uv += (M/RENDERSIZE)*speed;

    if(rotate) {
        uv *= rotate2d(t);
    }
    
    vec3 col = vec3(0);
    
    for(float i=0.; i<1.; i+=1./layers) {
    	float depth = fract(i+t);
        
        float scale = mix(depthFactor.x, depthFactor.y, depth);
        float fade = depth*smoothstep(1., .9, depth);
        col += StarLayer(uv*scale+i*1763.2)*fade;
    }
    
    col = pow(col, vec3(gamma));	// gamma correction
    
    gl_FragColor = vec4(col,alpha);
}
