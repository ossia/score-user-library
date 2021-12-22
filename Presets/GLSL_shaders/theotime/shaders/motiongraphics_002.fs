// @lsdlive
// CC-BY-NC-SA

// www.moduloprime.com
// Motion Graphics #002

// Checkout this on shadertoy: https://www.shadertoy.com/view/wt3SRl

// With the help of https://thebookofshaders.com/examples/?chapter=motionToolKit
// Inspired by: https://thebookofshaders.com/edit.php?log=160909064609


/*{
    "DESCRIPTION": "Motion Graphics #002",
    "CREDIT": "www.moduloprime.com",
    "CATEGORIES": [
        "Generator"
    ],
    "INPUTS": [
    {
        "NAME": "bpm",
        "LABEL": "BPM",
        "TYPE": "float",
        "DEFAULT": 120,
        "MIN": 0
    },
    {
        "NAME": "speed",
        "LABEL": "Speed",
        "TYPE": "float",
        "DEFAULT": 0.5,
        "MIN": 0
    },
    {
        "NAME": "resync",
        "LABEL": "Resync",
        "TYPE": "float",
        "DEFAULT": 0
    },
    {
        "NAME": "blink_factor",
        "LABEL": "Blink Factor",
        "TYPE": "float",
        "DEFAULT": 0,
        "MIN": 0,
        "MAX": 0.25
    }
    ]
}*/


const float pi = 3.141592654;
const float AA = 3.;

#define g_time (speed*(bpm/60.)*(resync+TIME))

// https://lospec.com/palette-list/1bit-monitor-glow
//vec3 col1 = vec3(.133, .137, .137);
//vec3 col2 = vec3(.941, .965, .941);

mat2 r2d(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, s, -s, c);
}

float fill(float d) {
    return 1. - smoothstep(0., AA / RENDERSIZE.x, d);
}

// inspired by Pixel Spirit Deck: https://patriciogonzalezvivo.github.io/PixelSpiritDeck/
// + https://www.shadertoy.com/view/tsSXRz
float stroke(float d, float width) {
    return 1. - smoothstep(0., AA / RENDERSIZE.x, abs(d) - width * .5);
}

float circle(vec2 p, float radius) {
    return length(p) - radius;
}

float pulse(float begin, float end, float t) {
    return step(begin, t) - step(end, t);
}

float easeInOutExpo(float t) {
    if (t == 0. || t == 1.) {
        return t;
    }
    if ((t *= 2.) < 1.) {
        return .5 * exp2(10. * (t - 1.));
    }
    else {
        return .5 * (-exp2(-10. * (t - 1.)) + 2.);
    }
}

void main() {
    vec2 uv = (gl_FragCoord.xy - .5 * RENDERSIZE.xy) / RENDERSIZE.y;

    float mask;

    float t1 = fract(.125 + g_time * .25); // for blinking rings
    float t2 = easeInOutExpo(fract(g_time));// for easing ring

    // blinking rings
    if (uv.x < 0.) {
        if (uv.y < 0. && pulse(0., .25 - blink_factor, t1) == 1.) {
            mask = fill(circle(uv, .35));
            mask += stroke(circle(uv, .3725), .005);
        }
        else if (uv.y > 0. && pulse(.25, .5 - blink_factor, t1) == 1.) {
            mask = fill(circle(uv, .35));
            mask += stroke(circle(uv, .3725), .005);
        }
    }
    else {
        if (uv.y > 0. && pulse(.5, .75 - blink_factor, t1) == 1.) {
            mask = fill(circle(uv, .35));
            mask += stroke(circle(uv, .3725), .005);
        }
        else if (uv.y < 0. && pulse(.75, 1. - blink_factor, t1) == 1.) {
            mask = fill(circle(uv, .35));
            mask += stroke(circle(uv, .3725), .005);
        }
    }

    // opposite blinking rings
    if (uv.x < 0.) {
        if (uv.y < 0. && pulse(.5, .75 - blink_factor, t1) == 1.) {
            mask = stroke(circle(uv, .25), .05);
            mask += stroke(circle(uv, .2), .005);
        }
        else if (uv.y > 0. && pulse(.75, 1. - blink_factor, t1) == 1.) {
            mask = stroke(circle(uv, .25), .05);
            mask += stroke(circle(uv, .2), .005);
        }
    }
    else {
        if (uv.y > 0. && pulse(0., .25 - blink_factor, t1) == 1.) {
            mask = stroke(circle(uv, .25), .05);
            mask += stroke(circle(uv, .2), .005);
        }
        else if (uv.y < 0. && pulse(.25, .5 - blink_factor, t1) == 1.) {
            mask = stroke(circle(uv, .25), .05);
            mask += stroke(circle(uv, .2), .005);
        }
    }


    // easing ring
    vec2 uv2 = uv * r2d(-pi / 2. * (floor(g_time) + t2));
    if (uv2.x < 0. && uv2.y < 0.)
        mask -= 2. * stroke(circle(uv2, .15), .05);
    mask += stroke(circle(uv, .15), .05);


    // outer rings + central circle
    mask -= fill(circle(uv, .09));
    mask += stroke(circle(uv, .4), .01);
    mask += stroke(circle(uv, .43), .01);

    mask = clamp(mask, 0., 1.);
    //vec3 col = mix(col1, col2, mask);
    vec3 col = vec3(mask); // black & white mask for VJ tool

    gl_FragColor = vec4(col, mask);
}