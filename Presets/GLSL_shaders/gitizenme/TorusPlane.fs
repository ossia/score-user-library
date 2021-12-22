/*{
    "CATEGORIES": [
        "Torus",
        "Fractal",
        "Sigmoid",
        "Deformation"
    ],
    "DESCRIPTION": "Torus Plan",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "LABEL": "position",
            "NAME": "pos",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": 0.05,
            "LABEL": "rate",
            "MAX": 1,
            "MIN": -1,
            "NAME": "rate",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "rotation",
            "MAX": 1,
            "MIN": -1,
            "NAME": "rotation",
            "TYPE": "float"
        },
        {
            "DEFAULT": 4,
            "LABEL": "iterations",
            "MAX": 10,
            "MIN": 0,
            "NAME": "iter",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.12,
            "LABEL": "radius",
            "MAX": 0.36,
            "MIN": 0,
            "NAME": "radius",
            "TYPE": "float"
        },
        {
            "DEFAULT": 24,
            "LABEL": "sharpness",
            "MAX": 200,
            "MIN": 6,
            "NAME": "sharpness",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1.2,
            "LABEL": "luminance",
            "MAX": 4,
            "MIN": 0,
            "NAME": "luminance",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "zoom",
            "MAX": 2,
            "MIN": -2,
            "NAME": "zoom",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.2,
            "LABEL": "red",
            "MAX": 1,
            "MIN": 0,
            "NAME": "red",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.1,
            "LABEL": "green",
            "MAX": 1,
            "MIN": 0,
            "NAME": "green",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "blue",
            "MAX": 1,
            "MIN": 0,
            "NAME": "blue",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "alpha",
            "MAX": 1,
            "MIN": 0,
            "NAME": "alpha",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/

mat2 scale(vec2 _scale){
    return mat2(_scale.x,0.0,
                0.0,_scale.y);
}

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

vec2 complex_mul(vec2 factorA, vec2 factorB){
   return vec2( factorA.x*factorB.x - factorA.y*factorB.y, factorA.x*factorB.y + factorA.y*factorB.x);
}

vec2 torus_mirror(vec2 uv){
	return vec2(1.)-abs(fract(uv*.5)*2.-1.);
}

float circle(vec2 uv, float scale){
	return clamp( 1. - length((uv-0.5)*scale), 0., 1.);
}

float sigmoid(float x) {
	return 2./(1. + exp2(-x)) - 1.;
}

float smoothcircle(vec2 uv, float radius, float sharpness){
	return 0.5 - sigmoid( ( length( (uv - 0.5)) - radius) * sharpness) * 0.5;
}

float border(vec2 domain, float thickness){
   vec2 uv = fract(domain-vec2(0.5));
   uv = min(uv,1.-uv)*2.;
   return clamp(max(uv.x,uv.y)-1.+thickness,0.,1.)/(thickness);
}

#define PI 3.14159265359


void main() {

	vec2 aspect = vec2(1.,RENDERSIZE.y/RENDERSIZE.x);
	vec2 uv = 0.5 + (gl_FragCoord.xy * vec2(1./RENDERSIZE.x,1./RENDERSIZE.y) - 0.5)*aspect;
	vec2 mouse = pos.xy / RENDERSIZE.xy;
	float mouseW = atan((mouse.y - 0.5)*aspect.y, (mouse.x - 0.5)*aspect.x);
	vec2 mousePolar = vec2(sin(mouseW), cos(mouseW));
	vec2 offset = (mouse - 0.5)*4.;
	offset =  - complex_mul(offset, mousePolar) + TIME*rate;

    uv -= vec2(0.5);
	uv = rotate2d( -(TIME*rotation)*PI ) * uv;
    uv = scale( vec2(-(TIME*zoom)+1.0) ) * uv;
    uv += vec2(0.5);

	vec2 uv_distorted = uv;

	for (float i = 0.0; i < iter; i++){
		float filter = smoothcircle(uv_distorted, radius, sharpness);
		uv_distorted = torus_mirror(0.5 + complex_mul(((uv_distorted - 0.5)*mix(2., 16., filter)), mousePolar) + offset);
	}


	gl_FragColor = vec4(circle(uv_distorted, luminance)*red, circle(uv_distorted, luminance)*green, circle(uv_distorted, luminance)*blue, alpha);
	// gl_FragColor.xy = uv_distorted; // domain map
}
