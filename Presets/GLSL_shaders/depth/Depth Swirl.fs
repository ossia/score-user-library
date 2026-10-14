/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Depth-twisted swirl. Each pixel's UV is rotated around a centre point by an angle proportional to its eye depth plus time. Near stuff rotates slowly, far stuff fast — produces a portal / trippy corkscrew effect.",
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
        { "NAME": "center", "TYPE": "point2D", "LABEL": "Swirl centre",
          "DEFAULT": [0.5, 0.5], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] },
        { "NAME": "swirlAmount", "TYPE": "float", "LABEL": "Swirl amount at far plane (radians)",
          "DEFAULT": 3.14, "MIN": -12.0, "MAX": 12.0 },
        { "NAME": "swirlSpeed", "TYPE": "float", "LABEL": "Swirl rotation speed (rad/s)",
          "DEFAULT": 0.5, "MIN": -5.0, "MAX": 5.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units for full swirl)",
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
    float ang   = t * swirlAmount + TIME * swirlSpeed;

    // Correct for aspect so the swirl is circular rather than elliptical.
    float aspect = RENDERSIZE.x / RENDERSIZE.y;
    vec2 p = (uv - center) * vec2(aspect, 1.0);
    float c = cos(ang), s = sin(ang);
    p = mat2(c, -s, s, c) * p;
    vec2 sampleUV = center + p * vec2(1.0 / aspect, 1.0);

    vec4 color = IMG_NORM_PIXEL(inputImage, sampleUV);
    isf_FragColor = color;
    gl_FragDepth = rawD;
}
