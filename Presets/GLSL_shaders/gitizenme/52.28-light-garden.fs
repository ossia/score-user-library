/*
{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/stfSDN by oneshade.  Testing with lots of lights. Doing a 10x10 loop does not seem smart!\nWell anyway it has a nice warm look to it like I intended :)\nMove around with the arrow keys and mouse.",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "NAME": "iMouse",
            "TYPE": "point2D"
        },
        {
            "NAME": "iChannel1",
            "TYPE": "audio"
        }
    ],
    "PASSES": [
        {
        },
        {
            "FLOAT": true,
            "PERSISTENT": true,
            "TARGET": "BufferA"
        },
        {
        }
    ]
}

*/


// Constants
#define PI 3.14159265359
#define RHO 1.57079632679

// State loading
#define getPosition() texelFetch(iChannel0, ivec2(0), 0).xyz
#define keyUpPressed() bool(texelFetch(iChannel1, ivec2(38, 0), 0).x)
#define keyDownPressed() bool(texelFetch(iChannel1, ivec2(40, 0), 0).x)
#define keyRightPressed() bool(texelFetch(iChannel1, ivec2(39, 0), 0).x)
#define keyLeftPressed() bool(texelFetch(iChannel1, ivec2(37, 0), 0).x)

// Camera matrix
mat3 getCamera(in vec2 viewDir) {
    vec2 c = cos(viewDir); vec2 s = sin(viewDir);
    return mat3(       c.x, 0.0,         s.x,  // Right
                s.x * -s.y, c.y, -c.x * -s.y,  // Up
                s.x *  c.y, s.y, -c.x *  c.y); // Forward
}
// Camera position buffer
// https://www.shadertoy.com/view/4djSRW
vec2 Hash22(in vec2 p) {
	vec3 p3 = fract(p.xyx * vec3(0.1031, 0.103, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

vec3 Hash33(in vec3 p) {
	p = fract(p * vec3(0.1031, 0.103, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.xxy + p.yxx) * p.zyx);
}

// https://www.shadertoy.com/view/slXXD4
// Simplified to assume the ray is normalized
float integrateLightFullView(in vec3 ro, in vec3 rd, in float k, in float d) {
    float b = dot(ro, rd);
    float c = dot(ro, ro) + d * d;
    float h = sqrt(c - b * b);
    return d * d * k * (RHO - atan(b / h)) / h;
}

void main() {
	if (PASSINDEX == 0)	{
	}
	else if (PASSINDEX == 1)	{
	    gl_FragColor = vec4(0.0, 50.0, 50.0, 0.0);
	    if (FRAMEINDEX > 0) {
	        ivec2 addr = ivec2(gl_FragCoord.xy);
	        if (addr == ivec2(0)) {
	            gl_FragColor = vec4(getPosition(), 0.0);
	
	            vec2 viewDir = (iMouse.xy - 0.5 * RENDERSIZE.xy) / RENDERSIZE.y * PI;
	            mat3 cam = getCamera(viewDir);
	
	            if (keyUpPressed()) gl_FragColor.xyz += cam[2] * 0.5;
	            if (keyDownPressed()) gl_FragColor.xyz -= cam[2] * 0.5;
	            if (keyRightPressed()) gl_FragColor.xyz += cam[0] * 0.5;
	            if (keyLeftPressed()) gl_FragColor.xyz -= cam[0] * 0.5;
	        }
	    }
	}
	else if (PASSINDEX == 2)	{
	    vec2 center = 0.5 * RENDERSIZE.xy;
	    vec2 uv = (gl_FragCoord.xy - center) / RENDERSIZE.y;
	    float time = TIME * 2.0;
	    gl_FragColor = vec4(0.0);
	
	    // Camera ray
	    vec2 viewDir = ivec2(iMouse.xy) == ivec2(0) ? vec2(0.0, -0.6) : (iMouse.xy - center) / RENDERSIZE.y * PI;
	    mat3 cam = getCamera(viewDir);
	
	    vec3 ro = getPosition();
	    vec3 rd = normalize(cam * vec3(uv, 1.0));
	
	    // Lights
	    for (float x=-50.0; x < 51.0; x += 10.0) {
	        for (float y=-50.0; y < 51.0; y += 10.0) {
	            vec2 horiPos = vec2(x, y);
	            horiPos += 8.0 * Hash22(horiPos) - 4.0;
	            float height = IMG_NORM_PIXEL(iChannel1,mod(vec2(length(horiPos) / 70.0, 0.0),1.0)).x * 30.0;
	            vec3 colorLast = normalize(Hash33(vec3(horiPos, floor(time))));
	            vec3 colorNext = normalize(Hash33(vec3(horiPos, ceil(time))));
	            gl_FragColor.rgb += integrateLightFullView(ro - vec3(horiPos, height).xzy, rd, 2.0, 0.25) * mix(colorLast, colorNext, fract(time));
	        }
	    }
	
	    gl_FragColor.rgb *= vec3(1.0, 0.8, 0.5);
	}

}
