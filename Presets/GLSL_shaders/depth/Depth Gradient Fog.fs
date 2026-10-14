/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Two-colour gradient fog. Mixes the scene toward nearColor between fogStart and fogMid, then toward farColor between fogMid and fogEnd, all in view-space eye-depth (world units). The fog is painted over the input, so the transparent sky of a scene gets fog at the fog's own opacity.",
    "CATEGORIES": ["Post-process", "Atmosphere"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "DEPTH": true,
          "LABEL": "Scene color + depth" },

        {
            "NAME": "camera", "TYPE": "uniform",
            "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" }
            ]
        },

        { "NAME": "nearColor", "TYPE": "color",
          "LABEL": "Near gradient colour",
          "DEFAULT": [0.95, 0.55, 0.3, 1.0] },
        { "NAME": "farColor",  "TYPE": "color",
          "LABEL": "Far gradient colour",
          "DEFAULT": [0.15, 0.1, 0.35, 1.0] },

        { "NAME": "fogStart", "TYPE": "float",
          "LABEL": "Fog start (world units)",
          "DEFAULT": 2.0,  "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "fogMid",   "TYPE": "float",
          "LABEL": "Fog mid point (world units)",
          "DEFAULT": 20.0, "MIN": 0.0, "MAX": 5000.0 },
        { "NAME": "fogEnd",   "TYPE": "float",
          "LABEL": "Fog end (world units)",
          "DEFAULT": 60.0, "MIN": 0.1, "MAX": 10000.0 },

        { "NAME": "fogAmount", "TYPE": "float",
          "LABEL": "Fog amount",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "fogSky", "TYPE": "bool",
          "LABEL": "Fog the sky",
          "DEFAULT": true }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye = dh_linearizeDepth(rawD, camera.projection);

    // Two-stage gradient: scene → nearColor across [start..mid],
    // then nearColor → farColor across [mid..end].
    float tNear = dh_smoothstep(fogStart, fogMid, eye);
    float tFar  = dh_smoothstep(fogMid,   fogEnd, eye);

    vec3 fogRgb = mix(nearColor.rgb, farColor.rgb, tFar);
    float coverage = tNear * fogAmount;

    if (!fogSky && dh_isSky(rawD)) {
        coverage = 0.0;
    }

    // The cleared sky has alpha 0: keep what this shader paints over it visible.
    isf_FragColor = dh_paintOver(color, fogRgb, coverage);
    gl_FragDepth = rawD;
}
