/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Radial motion blur scaled by depth. Samples along a ray from a user-chosen centre point toward each pixel, with step length growing with eye depth. Near stays frozen, far smears outward — warp-speed but depth-aware. The blur works on premultiplied colour and alpha, so a blurred silhouette also spreads over a transparent background.",
    "CATEGORIES": ["Post-process", "Focus"],
    "ALPHA": "premultiplied",

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
        { "NAME": "center", "TYPE": "point2D", "LABEL": "Blur centre (screen UV)",
          "DEFAULT": [0.5, 0.5], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] },
        { "NAME": "blurAmount", "TYPE": "float", "LABEL": "Blur strength",
          "DEFAULT": 0.05, "MIN": 0.0, "MAX": 0.5 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units at which blur saturates)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 },
        { "NAME": "samples", "TYPE": "long", "LABEL": "Sample count",
          "VALUES": [8, 16, 24, 32], "LABELS": ["8", "16", "24", "32"], "DEFAULT": 16 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL_PREMULTIPLIED(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye = dh_linearizeDepth(rawD, camera.projection);
    float depthFactor = clamp(eye / depthScale, 0.0, 1.0);
    vec2  dir = (uv - center) * blurAmount * depthFactor;

    if (length(dir) < 1.0 / RENDERSIZE.x) {
        isf_FragColor = color; gl_FragDepth = rawD; return;
    }

    vec4 acc = vec4(0.0);
    for (int i = 0; i < samples; ++i) {
        float t = float(i) / float(samples - 1);
        acc += IMG_NORM_PIXEL_LOD0(inputImage, uv - dir * t);
    }

    isf_FragColor = acc / float(samples);
    gl_FragDepth = rawD;
}
