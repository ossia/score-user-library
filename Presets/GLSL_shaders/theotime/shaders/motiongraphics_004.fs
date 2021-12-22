// @lsdlive
// CC-BY-NC-SA

// www.moduloprime.com
// Motion Graphics #004

// Checkout this on shadertoy: https://www.shadertoy.com/view/WtGXWW

// With the help of: https://thebookofshaders.com/examples/?chapter=motionToolKit


/*{
    "DESCRIPTION": "Motion Graphics #004",
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
        "NAME": "samples_dx",
        "LABEL": "Samples",
        "TYPE": "float",
        "DEFAULT": 0.05,
        "MIN": 0.05,
        "MAX": 0.5
    },
    {
        "NAME": "position_x",
        "LABEL": "Position X",
        "TYPE": "float",
        "DEFAULT": 0.4,
        "MIN": 0,
        "MAX": 0.5
    },
    {
        "NAME": "position_y",
        "LABEL": "Position y",
        "TYPE": "float",
        "DEFAULT": 1,
        "MIN": 0,
        "MAX": 5
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
const float pi_half = 1.570796327;
const float AA = 5.;

#define g_time (speed*(bpm/60.)*(resync+TIME))

// https://lospec.com/palette-list/1bit-monitor-glow
//vec3 col1 = vec3(.133, .137, .137);
//vec3 col2 = vec3(.941, .965, .941);

// inspired by Pixel Spirit Deck: https://patriciogonzalezvivo.github.io/PixelSpiritDeck/
// + https://www.shadertoy.com/view/tsSXRz
float stroke(float d, float width) {
    return 1. - smoothstep(0., AA / RENDERSIZE.x, abs(d) - width * .5);
}

float circle(vec2 p, float radius) {
    return length(p) - radius;
}

// https://thebookofshaders.com/edit.php?log=160909064320
float easeInOutQuad(float t) {
    if ((t *= 2.) < 1.) {
        return .5 * t * t;
    }
    else {
        return -.5 * ((t - 1.) * (t - 3.) - 1.);
    }
}

void main() {
    vec2 uv = (gl_FragCoord.xy - .5 * RENDERSIZE.xy) / RENDERSIZE.y;

    float t = fract(g_time * .25);
    float t_pi = t * 2. * pi;
    float t_pi_ease = 2. * pi * easeInOutQuad(t);

    // Construct a sphere with ellipses:
    // ellipse pos.y = sin(a) * sphere_radius
    // ellipse radius = cos(a) * sphere_radius
    // then, animate some values
    float sphere_radius = .3;
    vec2 ellipse_scale = vec2(1., 2.);
    float mask;
    for (float a = -pi_half; a < pi_half; a += samples_dx) {
        vec2 pos = vec2(
            cos(pi * .25 + 2. * a + t_pi) * position_x,
            sphere_radius * sin(a) * cos(position_y * a * a + t_pi_ease));// y

        pos.y *= 1.2; // y scaling adjustement
        float radius = sphere_radius * cos(a) + .1 * cos(t_pi) * sin(t_pi);// x
        float sdf = circle((uv - pos) * ellipse_scale, radius);

        mask += stroke(sdf, .005);
    }

    mask = clamp(mask, 0., 1.);
    //vec3 col = mix(col1, col2, mask);
    vec3 col = vec3(mask); // black & white mask for VJ tool

    gl_FragColor = vec4(col, mask);
}
