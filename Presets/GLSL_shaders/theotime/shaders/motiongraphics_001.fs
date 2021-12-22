// @lsdlive
// CC-BY-NC-SA

// www.moduloprime.com
// Motion Graphics #001

// Checkout this on shadertoy: https://www.shadertoy.com/view/tlcXD8

// With the help of https://thebookofshaders.com/examples/?chapter=motionToolKit
// With the help of Flopine, FabriceNeyret2, Pixel Spirit Deck.


/*{
    "DESCRIPTION": "Motion Graphics #001",
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
        "NAME": "ring_base_sz",
        "LABEL": "Ring size",
        "TYPE": "float",
        "DEFAULT": 0.0125,
        "MIN": 0
    },
    {
        "NAME": "ring_base_width",
        "LABEL": "Ring width",
        "TYPE": "float",
        "DEFAULT": 0.1,
        "MIN": -0.01,
        "MAX": 1.1
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

// from: pixelspiritdeck.com
float flip(float value, float percent) {
    return mix(value, 1. - value, percent);
}

float circle(vec2 p, float radius) {
    return length(p) - radius;
}

// https://thebookofshaders.com/edit.php?log=160909064320
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

// not used, but can be
float easeInOutQuad(float t) {
    if ((t *= 2.) < 1.) {
        return .5 * t * t;
    }
    else {
        return -.5 * ((t - 1.) * (t - 3.) - 1.);
    }
}

// not used, but can be
float easeInOutCubic(float t) {
    if ((t *= 2.) < 1.) {
        return .5 * t * t * t;
    }
    else {
        return .5 * ((t -= 2.) * t * t + 2.);
    }
}

void main(void) {
    vec2 uv = (gl_FragCoord.xy - .5 * RENDERSIZE.xy) / RENDERSIZE.y;

    // rotation animation
    float t = easeInOutExpo(fract(g_time));
    uv *= r2d((pi / 2.) * (floor(g_time) + t));

    // ring size animation
    float offs = .5;
    t = easeInOutExpo(fract(g_time + offs));
    float anim_sz = .125 + .125 * sin(pi * .75 + pi * (floor(g_time + offs) + t));

    float mask = flip(stroke(circle(uv, ring_base_sz + anim_sz), ring_base_width),
        fill(uv.x));

    //vec3 col = mix(col1, col2, mask);
    vec3 col = vec3(mask); // black & white mask for VJ tool
    gl_FragColor = vec4(col, mask);
}
