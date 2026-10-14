/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Linear blur whose direction rotates with depth. Near pixels blur along one axis, far along another — combined with twistAngle, the blur direction pivots through the scene, making the whole frame feel like it's being twisted. The blur works on premultiplied colour and alpha, so a blurred silhouette also spreads over a transparent background.",
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
        { "NAME": "blurAmount", "TYPE": "float", "LABEL": "Blur length (pixels)",
          "DEFAULT": 20.0, "MIN": 0.0, "MAX": 120.0 },
        { "NAME": "twistAngle", "TYPE": "float", "LABEL": "Angle twist across scene (degrees)",
          "DEFAULT": 180.0, "MIN": 0.0, "MAX": 720.0 },
        { "NAME": "baseAngle", "TYPE": "float", "LABEL": "Base angle at near plane (degrees)",
          "DEFAULT": 0.0, "MIN": 0.0, "MAX": 360.0 },
        { "NAME": "depthScale", "TYPE": "float", "LABEL": "Depth scale (world units mapped to full twist)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL_PREMULTIPLIED(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye = dh_linearizeDepth(rawD, camera.projection);
    float t   = clamp(eye / depthScale, 0.0, 1.0);
    float angDeg = baseAngle + twistAngle * t;
    float ang = radians(angDeg);
    vec2 dir  = vec2(cos(ang), sin(ang));

    const int N = 12;
    vec2 texel = 1.0 / RENDERSIZE;
    vec4 acc = vec4(0.0);
    for (int i = -N/2; i <= N/2; ++i) {
        float fi = float(i) / float(N/2);
        acc += IMG_NORM_PIXEL_LOD0(inputImage, uv + dir * fi * blurAmount * texel);
    }

    isf_FragColor = acc / float(N + 1);
    gl_FragDepth = rawD;
}
