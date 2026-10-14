/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Underwater-style wave distortion: each depth layer wobbles with its own phase offset, so the scene ripples as if seen through moving water. Independent X and Y wave frequencies let you dial between heat-haze (X only), curtain (Y only), and full rippling pool.",
    "CATEGORIES": ["Post-process", "Warp"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "waveAmount", "TYPE": "float", "LABEL": "Wave amplitude (pixels)",
          "DEFAULT": 6.0, "MIN": 0.0, "MAX": 80.0 },
        { "NAME": "waveFreqX", "TYPE": "float", "LABEL": "Wave frequency X",
          "DEFAULT": 4.0, "MIN": 0.0, "MAX": 40.0 },
        { "NAME": "waveFreqY", "TYPE": "float", "LABEL": "Wave frequency Y",
          "DEFAULT": 6.0, "MIN": 0.0, "MAX": 40.0 },
        { "NAME": "waveSpeed", "TYPE": "float", "LABEL": "Wave speed",
          "DEFAULT": 1.5, "MIN": 0.0, "MAX": 20.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units for 1 phase cycle)",
          "DEFAULT": 10.0, "MIN": 0.01, "MAX": 200.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);
    float phase = eye / depthScale * 6.28318 + TIME * waveSpeed;

    vec2 texel = 1.0 / RENDERSIZE;
    vec2 wob = vec2(
        sin(uv.y * waveFreqX * 6.28318 + phase) * waveAmount,
        cos(uv.x * waveFreqY * 6.28318 + phase * 0.7) * waveAmount
    ) * texel;

    vec4 color = IMG_NORM_PIXEL(inputImage, uv + wob);
    isf_FragColor = color;
    gl_FragDepth = rawD;
}
