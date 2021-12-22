/*{
    "CATEGORIES": [
        "Slider",
        "Elipitcal"
    ],
    "DESCRIPTION": "Sliding eliptical with a bit of warp",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": -2,
            "LABEL": "Scale",
            "MAX": 10,
            "MIN": -10,
            "NAME": "scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Rotaion Angle A",
            "MAX": 360,
            "MIN": 0,
            "NAME": "rotationAngleA",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Rotaion Angle B",
            "MAX": 360,
            "MIN": 0,
            "NAME": "rotationAngleB",
            "TYPE": "float"
        },
        {
            "DEFAULT": 110.0,
            "LABEL": "Ripples",
            "MAX": 400,
            "MIN": 1,
            "NAME": "ripples",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "Bulge",
            "MAX": 10,
            "MIN": -1,
            "NAME": "bulge",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.75,
            "LABEL": "Width",
            "MAX": 1,
            "MIN": 0.5,
            "NAME": "width",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.25,
            "LABEL": "Radius",
            "MAX": 1,
            "MIN": 0.01,
            "NAME": "radius",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.7,
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
            "DEFAULT": 0.9,
            "LABEL": "blue",
            "MAX": 1,
            "MIN": 0,
            "NAME": "blue",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.1,
            "LABEL": "Blend Red",
            "MAX": 1,
            "MIN": 0.01,
            "NAME": "blendRed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.1,
            "LABEL": "Blend Green",
            "MAX": 1,
            "MIN": 0.01,
            "NAME": "blendGreen",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "Blend Blue",
            "MAX": 1,
            "MIN": 0.01,
            "NAME": "blendBlue",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/

mat2 rotate(float angle)
{
    return mat2( cos(angle),-sin(angle),sin(angle),cos(angle) );
}

float Slider(vec2 p, float w, float r, float b) {
    // p = point to evaluate
    // w = half distance between end points
    // r = radius of endpoints
    // b = bulge -> -1 = pinch to center 0 = straight >0 = bulge out
    
    if(abs(b)<1e-7) b = 1e-7;	// prevent division by 0
    float sb = sign(b);
    
    p = abs(p);
    
    vec2 ep = p-vec2(w, 0);			// end point
    float dE = length(ep)-r;		// distance to end circle
    float y = (w*w-r*r)/(2.*r*b);	// height of center circle
    vec2 cp = vec2(p.x, p.y-y);		// position of center circle
    vec2 ec = sb*(ep-cp);			// vec from end point to center point
    float rc = length(ec)-r*sb;		// radius of center circle
    float dC = sb*(rc-length(cp));	// distance to center circle
    
    return ec.x*ep.y-ec.y*ep.x < 0. ? dE : dC;
}

void main() {
    vec2 uv = (gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;
    float t = TIME;
    
    uv *= scale;
    if(rotationAngleA > 0.) {
        uv *= -rotate(rotationAngleA);
    }
    else if(rotationAngleB > 0.) {
        uv *= rotate(rotationAngleB);
    }
    
    float d = Slider(uv, width, radius, bulge);

    // color
    vec3 col = vec3(blendRed, blendGreen, blendBlue) - sign(d)*vec3(red,green,blue);
	col *= 1.0 - exp(-4.0*abs(d));
	col *= 0.1 + 0.8*cos(ripples*d);
	col = mix( col, vec3(red,green,blue), 1.0 - smoothstep(0.0,0.015,abs(d)) );
    
    gl_FragColor = vec4(col,1.0);
}
