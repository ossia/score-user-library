/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Depth-driven chromatic aberration. Each RGB channel samples at a slightly different UV offset, with the offset magnitude proportional to distance from the focus plane. Near and far both fringe in R/B; the focus plane stays clean. Analog-lens defect aesthetic.",
    "CATEGORIES": ["Post-process", "Warp"],

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
        { "NAME": "focusDepth", "TYPE": "float", "LABEL": "Focus depth (world units)",
          "DEFAULT": 8.0, "MIN": 0.01, "MAX": 1000.0 },
        { "NAME": "strength", "TYPE": "float", "LABEL": "Fringe strength (pixels per world-unit)",
          "DEFAULT": 0.4, "MIN": 0.0, "MAX": 10.0 },
        { "NAME": "center", "TYPE": "point2D", "LABEL": "Fringe centre",
          "DEFAULT": [0.5, 0.5], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);
    float mag   = abs(eye - focusDepth) * strength;

    vec2 texel = 1.0 / RENDERSIZE;
    vec2 dir = normalize(uv - center + vec2(1e-5));

    float r = IMG_NORM_PIXEL(inputImage, uv + dir * mag * texel).r;
    float g = IMG_NORM_PIXEL(inputImage, uv).g;
    float b = IMG_NORM_PIXEL(inputImage, uv - dir * mag * texel).b;
    float a = IMG_NORM_PIXEL(inputImage, uv).a;

    isf_FragColor = vec4(r, g, b, a);
    gl_FragDepth = rawD;
}
