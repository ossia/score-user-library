/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "X-Ray: past a user-defined depth cutoff, the scene inverts and shifts toward an X-ray tint. Pixels in front of the cutoff stay normal — so moving objects in the foreground stay opaque while distant structure 'shows through'. The X-ray layer is opaque: a transparent sky beyond the cutoff comes out as X-ray film (tint times intensity).",
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
        { "NAME": "cutoffDepth", "TYPE": "float", "LABEL": "Cutoff depth (world units)",
          "DEFAULT": 8.0, "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "feather", "TYPE": "float", "LABEL": "Feather (world units)",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 20.0 },
        { "NAME": "xrayTint", "TYPE": "color", "LABEL": "X-ray tint",
          "DEFAULT": [0.6, 0.85, 1.0, 1.0] },
        { "NAME": "xrayIntensity", "TYPE": "float", "LABEL": "X-ray intensity",
          "DEFAULT": 0.9, "MIN": 0.0, "MAX": 2.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);

    float mask = dh_smoothstep(cutoffDepth, cutoffDepth + feather, eye);

    vec3 inverted = 1.0 - color.rgb;
    vec3 xrayed   = inverted * xrayTint.rgb * xrayIntensity;
    // The cleared sky has alpha 0: keep what this shader paints over it visible.
    isf_FragColor = dh_paintOver(color, xrayed, mask);
    gl_FragDepth = rawD;
}
