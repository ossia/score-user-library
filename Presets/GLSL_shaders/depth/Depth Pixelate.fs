/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Depth-scaled pixelation. Blocks get larger with distance, so near content stays sharp while far content turns into chunky retro-console blocks. Set the near block size above the far one to reverse it: near = blocky, far = sharp.",
    "CATEGORIES": ["Post-process", "Stylise"],

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
        { "NAME": "nearBlock", "TYPE": "float", "LABEL": "Block size near (pixels)",
          "DEFAULT": 1.0, "MIN": 1.0, "MAX": 80.0 },
        { "NAME": "farBlock", "TYPE": "float", "LABEL": "Block size far (pixels)",
          "DEFAULT": 20.0, "MIN": 1.0, "MAX": 200.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units to reach farBlock)",
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
    float block = max(mix(nearBlock, farBlock, t), 1.0);

    vec2 blockSize = vec2(block) / RENDERSIZE;
    vec2 snappedUV = (floor(uv / blockSize) + 0.5) * blockSize;

    vec4 color = IMG_NORM_PIXEL(inputImage, snappedUV);
    isf_FragColor = color;
    gl_FragDepth = rawD;
}
