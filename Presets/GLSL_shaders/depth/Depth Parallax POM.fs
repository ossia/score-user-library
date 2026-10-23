/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Screen-space parallax occlusion: raymarches along the view direction for each fragment, stopping where the ray's computed depth first exceeds the sampled scene depth. Produces more accurate parallax than the one-shot offset — surfaces actually occlude each other. Single-pass but expensive. Move `viewShift` (0, 0 = no shift) to swing the virtual viewpoint.",
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
        { "NAME": "viewShift", "TYPE": "point2D", "LABEL": "Virtual view shift (screen-space)",
          "DEFAULT": [0.5, 0.25], "MIN": [-1.0, -1.0], "MAX": [1.0, 1.0] },
        { "NAME": "strength", "TYPE": "float", "LABEL": "Parallax strength",
          "DEFAULT": 0.08, "MIN": 0.0, "MAX": 0.5 },
        { "NAME": "steps", "TYPE": "long", "LABEL": "Raymarch steps",
          "VALUES": [8, 16, 32, 64], "LABELS": ["8", "16", "32", "64"], "DEFAULT": 16 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Normalisation scale (world units)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2 uv0 = isf_FragNormCoord;
    vec2 dir = viewShift * strength;

    // Linearised depth at the march start.
    float rayD = 0.0;
    float stepD = 1.0 / float(steps);

    vec2 uv = uv0;
    float hitD = 0.0;
    bool hit = false;
    for (int i = 1; i <= steps; ++i) {
        rayD = float(i) * stepD;
        uv = uv0 + dir * rayD;
        float rawS = IMG_DEPTH_NORM_PIXEL_LOD0(inputImage, uv);
        float eyeS = dh_linearizeDepth(rawS, camera.projection);
        float sceneD = clamp(eyeS / depthScale, 0.0, 1.0);
        if (rayD >= sceneD) {
            hitD = rayD;
            hit = true;
            break;
        }
    }

    vec4 color = IMG_NORM_PIXEL(inputImage, uv);
    float rawOut = hit ? IMG_DEPTH_NORM_PIXEL(inputImage, uv)
                       : IMG_DEPTH_NORM_PIXEL(inputImage, uv0);
    isf_FragColor = color;
    gl_FragDepth = rawOut;
}
