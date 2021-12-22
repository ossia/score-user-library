/*{
    "CATEGORIES": [
        "Stars",
        "Starfield"
    ],
    "DESCRIPTION": "Starfield",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                300,
                225
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
            "DEFAULT": 0.5,
            "MAX": 1,
            "MIN": 0,
            "NAME": "density",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.9,
            "MAX": 1,
            "MIN": 0,
            "NAME": "flareFactor",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.2,
            "MAX": 1.5,
            "MIN": 0.01,
            "NAME": "brightness",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "MAX": 10,
            "MIN": 0.01,
            "NAME": "scaleMin",
            "TYPE": "float"
        },
        {
            "DEFAULT": 20,
            "MAX": 40,
            "MIN": 0.01,
            "NAME": "scaleMax",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "MAX": 6.14,
            "MIN": -6.14,
            "NAME": "rotation",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/


// Starfield Tutorial by Martijn Steinrucken aka BigWings - 2020
// countfrolic@gmail.com
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// 

#define NUM_LAYERS 8.
#define PI 3.1415

mat2 Rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c, -s, s, c);
}

float Star(vec2 uv, float flare, float sizeOfStar) {
	float d = length(uv);

    float m = sizeOfStar/d;
    
    float sizeOfRay = 1000.;

    vec2 uvRot = uv;
    uvRot *= Rot(TIME * PI / 4. * 0.25);
    float ray = 1. - abs(uvRot.x * uvRot.y * sizeOfRay);

    float rayBrightness = .6;

    // eliminate negative rays
    float rays = max(0., ray);
    m += rays * rayBrightness * flare;

    // second set of rays at 45 degree angle
    uvRot = uv * Rot(PI / 4.);
    // uvRot *= Rot(PI / 4.);
    uvRot *= Rot(TIME * PI / 4. * 0.25);

    ray = 1. - abs(uvRot.x * uvRot.y * sizeOfRay);
    rays = max(0., ray);

    rayBrightness = .3;
    m += rays * rayBrightness * flare;
    
    // fade star flow
    m *= smoothstep(1., .2, d);

    return m;
}

float Hash21(vec2 p) {
    p = fract(p*vec2(123.34, 456.21));
    p += dot(p, p+45.32);
    return fract(p.x*p.y);
}

vec3 StarLayer(vec2 uv, float depth) {
	vec3 col = vec3(0);
	
    vec2 gv = fract(uv)-.5; // .5 = orgin in the middle
    // give each star an ID
    vec2 id = floor(uv);
    
    for(int y = -1; y <= 1; y++) {
    	for(int x =- 1; x <= 1; x++) {
            vec2 offs = vec2(x, y);
            
    		float n = Hash21(id + offs); // random between 0 and 1
            if(n < 1. - density) // && depth < NUM_LAYERS * 0.15)
                continue;

            float starBrightness = fract(n * brightness);
            
    		// float star = Star(gv-offs-vec2(n, fract(n*34.))+.5, smoothstep(.9, 1., starBrightness)*.6);
            float starSize = min(.7, fract(n * 786766.32));
            float flareOn = smoothstep(flareFactor, 1., fract(n * 345.32));

            vec2 starPos = gv - offs - vec2(n, fract(n * 3439.50)) + .5;
    		float star = Star(starPos, flareOn, starSize);
            
            // vec3 color = sin(vec3(.2, .3, .9) * fract(n * 2345.2) * 123.2) * .5 + .5;
            // color = color * vec3(1, .25, 1. + starBrightness) + vec3(.2, .2, .1) * 2.;
            
            vec3 color = vec3(0);
            if(n > 0.8) 
                color = vec3(0.8745098039, 0.0431372549, 0.0019607843); // 223	113	77	
            else if(n > 0.75)
                color = vec3(0.9176470588, 0.6509803922, 0.3294117647); // 234	166	84	
            else if(n > 0.70)
                color = vec3(0.9843137255, 0.9333333333, 0.4); // 251	238	102	
            else if(n > 0.65)
                color = vec3(1, 1, 1); // 255	255	255	
            else if(n > 0.60)
                color = vec3(0.3661971831, 0.5803921569, 0.9803921569); // 130	148	250	
            else if(n > 0.55)
                color = vec3(0.5098039216, 0.5803921569, 1); 
            else if(n > 0.4)
                color = vec3(0.1137254902, 0.03921568627, 0.9882352941); // 29	10	252	


            // star *= sin(TIME*3.+n*6.2831)*.5+1.;
            star *= sin(n * 6.2831) * .5 + 1.;
            col += star * color * starBrightness;
        }
    }
    return col;
}

int bpm = 60;
float bbpm = 1. / 4.;  // beats per measure
float spm = (bbpm * (float(bpm) / 60.)); // seconds per measure

void main() {

    vec2 uv = (gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;
	vec2 M = (pos.xy-RENDERSIZE.xy*.5)/RENDERSIZE.y;
    
    float t = TIME * spm * 0.125;

    uv += M; 
    uv *= Rot(t * rotation);
    
    vec3 col = vec3(0);
    
    for(float i = 0.; i < 1.; i += 1. / NUM_LAYERS) {
    	float depth = fract(i + t);
        
        float scale = mix(scaleMax, scaleMin, depth);
        float fade = depth * smoothstep(1., .9, depth);

        vec2 starLayerUV = uv * scale + i * 453.2 - M;
        col += StarLayer(starLayerUV, depth) * fade;
    }
    
    col = pow(col, vec3(.4545));	// gamma correction
    
    gl_FragColor = vec4(col,1.0);
}
