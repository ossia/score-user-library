/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Depth wipe with organic noise-shaped edge. Uses the same 'near-to-far' sweep as Depth Wipe, but the per-pixel threshold is perturbed by 2D value noise, giving a broken, ragged boundary — like the scene dissolving in chunks rather than a clean plane. The target colour is painted over the input, so it also covers a transparent sky (which counts as the far end).",
    "CATEGORIES": ["Post-process", "Slice"],

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
        { "NAME": "progress", "TYPE": "float", "LABEL": "Wipe progress (0..1)",
          "DEFAULT": 0.3, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "noiseAmount", "TYPE": "float", "LABEL": "Noise perturbation amount",
          "DEFAULT": 0.2, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "noiseScale", "TYPE": "float", "LABEL": "Noise spatial scale",
          "DEFAULT": 8.0, "MIN": 0.5, "MAX": 80.0 },
        { "NAME": "softness", "TYPE": "float", "LABEL": "Edge softness",
          "DEFAULT": 0.03, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "direction", "TYPE": "long", "LABEL": "Direction",
          "VALUES": [0, 1], "LABELS": ["Near → Far", "Far → Near"], "DEFAULT": 0 },
        { "NAME": "farCutoff", "TYPE": "float", "LABEL": "Far cutoff (world units)",
          "DEFAULT": 50.0, "MIN": 0.1, "MAX": 10000.0 },
        { "NAME": "targetColor", "TYPE": "color", "LABEL": "Wipe-to colour",
          "DEFAULT": [0.0, 0.0, 0.0, 1.0] }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float d01 = dh_normalizedEyeDepth(rawD, camera.projection, farCutoff);
    float n   = dh_valueNoise(uv * noiseScale) - 0.5;
    float x   = (direction == 0) ? d01 : (1.0 - d01);
    x += n * noiseAmount;

    float t = dh_smoothstep(progress - softness, progress + softness, x);
    isf_FragColor = dh_paintOver(color, targetColor.rgb, 1.0 - t);
    gl_FragDepth = rawD;
}
