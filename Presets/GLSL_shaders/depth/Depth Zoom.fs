/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Depth-modulated radial zoom. Near pixels keep their scale; far pixels zoom in toward (or out from) the centre point. Like a pure-2D dolly zoom.",
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
        { "NAME": "center", "TYPE": "point2D", "LABEL": "Zoom centre",
          "DEFAULT": [0.5, 0.5], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] },
        { "NAME": "zoomAmount", "TYPE": "float", "LABEL": "Zoom amount (positive = zoom in, negative = zoom out)",
          "DEFAULT": 0.5, "MIN": -2.0, "MAX": 2.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units to reach full zoom)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);
    float t     = clamp(eye / depthScale, 0.0, 1.0);
    float scale = 1.0 / (1.0 + zoomAmount * t);

    vec2 sampleUV = center + (uv - center) * scale;
    vec4 color = IMG_NORM_PIXEL(inputImage, sampleUV);
    isf_FragColor = color;
    gl_FragDepth = rawD;
}
