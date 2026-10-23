/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Depth-indexed palette lookup. Uses normalised eye depth as a U coordinate into the provided palette image (drag any gradient/texture in). Scene colour is either multiplied by or replaced with the palette colour. Makes arbitrary gradients trivially depth-aware. Multiply keeps the input's transparency; Replace paints the palette over it, so a transparent sky takes the palette's far end.",
    "CATEGORIES": ["Post-process", "Slice"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "IS_DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "paletteImage", "TYPE": "image", "LABEL": "Palette (U = depth, V = 0..1 optional banding)" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "farCutoff", "TYPE": "float", "LABEL": "Far cutoff (world units maps to U=1)",
          "DEFAULT": 50.0, "MIN": 0.1, "MAX": 10000.0 },
        { "NAME": "paletteV", "TYPE": "float", "LABEL": "Palette V coordinate",
          "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "blendMode", "TYPE": "long", "LABEL": "Blend",
          "VALUES": [0, 1], "LABELS": ["Multiply", "Replace"], "DEFAULT": 0 },
        { "NAME": "mixAmount", "TYPE": "float", "LABEL": "Mix (0 = scene, 1 = palette applied)",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float d01 = dh_normalizedEyeDepth(rawD, camera.projection, farCutoff);
    vec3 pal = IMG_NORM_PIXEL(paletteImage, vec2(d01, paletteV)).rgb;

    if (blendMode == 0)
        isf_FragColor = vec4(mix(color.rgb, color.rgb * pal, mixAmount), color.a);
    else
        isf_FragColor = dh_paintOver(color, pal, mixAmount);
    gl_FragDepth = rawD;
}
