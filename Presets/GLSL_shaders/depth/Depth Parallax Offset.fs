/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Parallax UV offset driven by depth — the Facebook-3D-photo trick. Near content stays put; far content shifts, giving a fake 3D illusion when the centre point moves. Tie `centerPoint` to a slow LFO or the audio for an inexpensive mock-3D effect.",
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
        { "NAME": "centerPoint", "TYPE": "point2D", "LABEL": "Parallax centre (move this around)",
          "DEFAULT": [0.5, 0.5], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] },
        { "NAME": "strength", "TYPE": "float", "LABEL": "Parallax strength",
          "DEFAULT": 0.08, "MIN": 0.0, "MAX": 0.5 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth saturation (world units)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye = dh_linearizeDepth(rawD, camera.projection);
    float t   = clamp(eye / depthScale, 0.0, 1.0);
    vec2 offset = (centerPoint - vec2(0.5)) * strength * t;

    vec4 color = IMG_NORM_PIXEL(inputImage, uv + offset);
    isf_FragColor = color;
    gl_FragDepth = rawD;
}
