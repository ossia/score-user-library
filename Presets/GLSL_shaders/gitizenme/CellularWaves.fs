/*{
    "CATEGORIES": [
        "Noise",
        "Worley",
        "Fluid",
        "Automatically Converted",
        "Shadertoy"
    ],
    "CREDIT": "Automatically converted from https://www.shadertoy.com/view/llS3RK by Kyle273.  A simple Worley noise shader. Full tutorial at ibreakdownshaders.blogspot.com. Original shader from  http://glslsandbox.com/e#23237.0",
    "DESCRIPTION": "Cellular Waves",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": 0.2,
            "LABEL": "Red",
            "MAX": 1,
            "MIN": 0,
            "NAME": "r",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.1,
            "LABEL": "Green",
            "MAX": 1,
            "MIN": 0,
            "NAME": "g",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.8,
            "LABEL": "Blue",
            "MAX": 1,
            "MIN": 0,
            "NAME": "b",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Alpha",
            "MAX": 1,
            "MIN": 0,
            "NAME": "a",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.8,
            "LABEL": "Gradient A",
            "MAX": 3,
            "MIN": 0,
            "NAME": "gradientA",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.8,
            "LABEL": "Gradient B",
            "MAX": 3,
            "MIN": 0,
            "NAME": "gradientB",
            "TYPE": "float"
        },
        {
            "DEFAULT": 43.13311,
            "LABEL": "Noise A",
            "MAX": 100,
            "MIN": 0,
            "NAME": "noiseA",
            "TYPE": "float"
        },
        {
            "DEFAULT": 31.0011,
            "LABEL": "Noise B",
            "MAX": 100,
            "MIN": 0,
            "NAME": "noiseB",
            "TYPE": "float"
        },
        {
            "DEFAULT": 4.0,
            "LABEL": "Luminance A",
            "MAX": 100,
            "MIN": 1,
            "NAME": "lumA",
            "TYPE": "float"
        },
        {
            "DEFAULT": 2.5,
            "LABEL": "Luminance B",
            "MAX": 100,
            "MIN": 1,
            "NAME": "lumB",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1500.0,
            "LABEL": "Scale",
            "MAX": 10000,
            "MIN": 100,
            "NAME": "scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.05,
            "LABEL": "Layer 1 Time",
            "MAX": 5,
            "MIN": -5,
            "NAME": "layer1Time",
            "TYPE": "float"
        },
        {
            "DEFAULT": -0.1,
            "LABEL": "Layer 2 Time",
            "MAX": 5,
            "MIN": -5,
            "NAME": "layer2Time",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.03,
            "LABEL": "Layer 3 Time",
            "MAX": 5,
            "MIN": -5,
            "NAME": "layer3Time",
            "TYPE": "float"
        },
        {
            "DEFAULT": 5.0,
            "LABEL": "Layer 1 Noise",
            "MAX": 100,
            "MIN": -100,
            "NAME": "layer1Noise",
            "TYPE": "float"
        },
        {
            "DEFAULT": 50.0,
            "LABEL": "Layer 2 Noise",
            "MAX": 100,
            "MIN": -100,
            "NAME": "layer2Noise",
            "TYPE": "float"
        },
        {
            "DEFAULT": -10.0,
            "LABEL": "Layer 3 Noise",
            "MAX": 100,
            "MIN": -100,
            "NAME": "layer3Noise",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/


//Calculate the squared length of a vector
float length2(vec2 p){
    return dot(p,p);
}

//Generate some noise to scatter points.
float noise(vec2 p){
	return fract(sin(fract(sin(p.x) * (noiseA)) + p.y) * noiseB);
}

float worley(vec2 p) {
    //Set our distance to infinity
	float d = lumA;
    //For the 9 surrounding grid points
	for (int xo = -1; xo <= 1; ++xo) {
		for (int yo = -1; yo <= 1; ++yo) {
            //Floor our vec2 and add an offset to create our point
			vec2 tp = floor(p) + vec2(xo, yo);
            //Calculate the minimum distance for this grid point
            //Mix in the noise value too!
			d = min(d, length2(p - tp - noise(tp)));
		}
	}
	return lumA*exp(-4.0*abs(lumB*d - 1.0));
}

float fworley(vec2 p) {
    //Stack noise layers 
    float layer1 = worley(p * layer1Noise + layer1Time*TIME);
    float layer2 = sqrt(worley(p * layer2Noise + 0.12 + layer2Time*TIME));
    float layer3 = sqrt(sqrt(worley(p * layer3Noise + layer3Time*TIME)));

    float layers = sqrt(layer1 * layer2 * layer3 );
	
    return sqrt(sqrt(layers));
}
      
void main() {
	vec2 uv = isf_FragNormCoord;
    //Calculate an intensity
    float t = fworley(uv * RENDERSIZE.xy / scale);
    //Add some gradient
    t *= exp(-length2(abs(gradientA*uv - gradientB)));	
    gl_FragColor = vec4(t * vec3(r, g, b), a);
}

