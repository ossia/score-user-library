// @lsdlive
// CC-BY-NC-SA

// www.moduloprime.com
// Motion Graphics #003

// Checkout this on shadertoy: https://www.shadertoy.com/view/3lyXzz

// With the help of: https://thebookofshaders.com/examples/?chapter=motionToolKit
// With the help of: https://patriciogonzalezvivo.github.io/PixelSpiritDeck/


/*{
    "DESCRIPTION": "Motion Graphics #003",
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
        "DEFAULT": 0.25,
        "MIN": 0
    },
    {
        "NAME": "cross_height",
        "LABEL": "Cross height",
        "TYPE": "float",
        "DEFAULT": 0.1,
        "MIN": 0,
        "MAX": 0.5
    },
    {
        "NAME": "cross_width",
        "LABEL": "Cross width",
        "TYPE": "float",
        "DEFAULT": 0.4,
        "MIN": 0,
        "MAX": 0.5
    },
    {
        "NAME": "circle_radius",
        "LABEL": "Circle radius",
        "TYPE": "float",
        "DEFAULT": 0.25,
        "MIN": 0,
        "MAX": 1
    },
    {
        "NAME": "circle_stroke",
        "LABEL": "Circle stroke",
        "TYPE": "float",
        "DEFAULT": 0.2,
        "MIN": 0,
        "MAX": 1
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

float bridge(float mask, float sdf, float w) {
    mask *= 1. - stroke(sdf, w * 2.);
    return mask + stroke(sdf, w);
}

float circle(vec2 p, float radius) {
    return length(p) - radius;
}

float rect(vec2 p, vec2 size) {
    vec2 d = abs(p) - size;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float easeInOutQuad(float t) {
    if ((t *= 2.) < 1.) {
        return .5 * t * t;
    }
    else {
        return -.5 * ((t - 1.) * (t - 3.) - 1.);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / RENDERSIZE.xy;
    uv.x *= RENDERSIZE.x / RENDERSIZE.y;

    float t1 = fract(g_time * .25);// sliding
    float t2 = fract(g_time);// rotation
    t2 = easeInOutQuad(t2);

    uv *= r2d(pi * .25);
    vec2 uv1 = fract((uv + t1) * 4.) - .5;
    vec2 uv2 = fract(((uv - vec2(t1, 0)) * 4.) + .5) - .5;

    // layer1 - cross
    float mask = fill(rect(uv1 * r2d(t2 * pi), vec2(cross_height, cross_width)));
    mask += fill(rect(uv1 * r2d(t2 * pi), vec2(cross_width, cross_height)));

    // layer2 - circle
    mask = bridge(mask, circle(uv2, circle_radius), circle_stroke);

    mask = clamp(mask, 0., 1.);
    //vec3 col = mix(col1, col2, mask);
    vec3 col = vec3(mask); // black & white mask for VJ tool

    gl_FragColor = vec4(col, mask);
}