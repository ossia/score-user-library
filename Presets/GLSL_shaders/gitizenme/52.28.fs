/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/MdsXWM by airtight.  Super basic audio-reactive HSL light ring. My first shader here :)",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": 0,
            "LABEL": "X Overlay",
            "MAX": 0.5,
            "MIN": -0.5,
            "NAME": "xOverlay",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Y Overlay",
            "MAX": 0.5,
            "MIN": -0.5,
            "NAME": "yOverlay",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Rotation Angle",
            "MAX": 10,
            "MIN": -10,
            "NAME": "rotationAngle",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "Amplitude",
            "MAX": 4,
            "MIN": 0.1,
            "NAME": "amplitude",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/


#define PI 3.1415

const float dots = 40.; //number of lights
const float radius = .25; //radius of light ring
const float brightness = 0.02;

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

//convert HSV to RGB
vec3 hsv2rgb(vec3 c){
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
		
void main() {

	vec2 p = (gl_FragCoord.xy - .5 * RENDERSIZE.xy) / min(RENDERSIZE.x, RENDERSIZE.y);
    
    vec3 c = vec3(0, 0, 0.1); //background color
		
	float bpm = 58.;
    float bbpm = 4.;  // beats per measure
    float spm = (bbpm*60./(bpm))/4.; // seconds per measure

    for(float i = 0.; i < dots; i++){
	
        float vol = amplitude * mod( vec2( i / dots, 0.0), 1.0).x;
		float b = vol * brightness;
		
		//get location of dot
        float x = radius * cos(2. * PI * float(i) / dots);
        float y = radius * sin(2. * PI * float(i) / dots);
        vec2 o = vec2(x, y);

        o = rotate2d( rotationAngle ) * o;

		//get color of dot based on its index in the 
		//circle + time to rotate colors
		vec3 dotCol = hsv2rgb(vec3((i + TIME * 20.) / dots, 0.8, 0.8));
	    
        //get brightness of this pixel based on distance to dot
		c += b / (length(p - o)) * dotCol;
    }
	
    // circle overlay
    float oX = radius * cos(PI * TIME / 2.) + radius / 4.;
    float oY = radius * sin(PI * TIME / 2.) + radius / 4.;    


    p = rotate2d( rotationAngle ) * p * (amplitude * amplitude);
    p += vec2(xOverlay, yOverlay) * 0.1;
    // p.x *= cos(PI * xOverlay / 2.) + 2. * p.y;
    // p.y *= sin(PI * yOverlay / 2.) + 1. * p.x;
    vec2 oP = vec2(radius - radius) / 2.;

	float dist = distance(p, oP);  
	c -= clamp(0.0, 0.5, smoothstep(0.01, 0.08, dist));
	 
	gl_FragColor = vec4(c, 1);
}
