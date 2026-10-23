/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Manga action lines: radial ink strokes radiating from a centre point, drawn only on far pixels so the subject (near) stays clean. Classic anime emphasis / impact-frame look. `lineDensity` controls how many rays, `lineJitter` makes them less regular. The lines are painted over the input, so they also cover a transparent sky (it counts as far).",
    "CATEGORIES": ["Post-process", "Stylise"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "IS_DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "center", "TYPE": "point2D", "LABEL": "Action centre",
          "DEFAULT": [0.5, 0.5], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] },
        { "NAME": "lineDensity", "TYPE": "float", "LABEL": "Line count",
          "DEFAULT": 60.0, "MIN": 4.0, "MAX": 400.0 },
        { "NAME": "lineThickness", "TYPE": "float", "LABEL": "Line thickness (0..1)",
          "DEFAULT": 0.25, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "lineJitter", "TYPE": "float", "LABEL": "Line jitter",
          "DEFAULT": 0.3, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "farStart", "TYPE": "float", "LABEL": "Lines begin at this depth (world units)",
          "DEFAULT": 5.0, "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "farEnd", "TYPE": "float", "LABEL": "Lines full at this depth (world units)",
          "DEFAULT": 20.0, "MIN": 0.01, "MAX": 10000.0 },
        { "NAME": "inkColor", "TYPE": "color", "LABEL": "Line colour",
          "DEFAULT": [0.0, 0.0, 0.0, 1.0] }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);
    float farMask = dh_smoothstep(farStart, farEnd, eye);

    // Polar coordinates around centre, aspect-corrected.
    float aspect = RENDERSIZE.x / RENDERSIZE.y;
    vec2 p = (uv - center) * vec2(aspect, 1.0);
    float angle = atan(p.y, p.x);
    float a01 = angle / DH_TWO_PI + 0.5;  // [0, 1]

    // Quantise angle into rays, jittered.
    float idx  = floor(a01 * lineDensity);
    float jit  = (dh_hash11(idx) - 0.5) * lineJitter;
    float pos  = fract(a01 * lineDensity + jit);
    float line = smoothstep(lineThickness * 0.5 + 0.02, lineThickness * 0.5 - 0.02, abs(pos - 0.5));

    isf_FragColor = dh_paintOver(color, inkColor.rgb, line * farMask);
    gl_FragDepth = rawD;
}
