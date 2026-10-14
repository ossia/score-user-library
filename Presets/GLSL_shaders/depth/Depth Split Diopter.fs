/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Split-diopter / zone-plate focus: two separate focus planes stay sharp, everything else blurs. Blur amount is the minimum distance to either plane. The blur works on premultiplied colour and alpha, so a blurred silhouette also spreads over a transparent background.",
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
        { "NAME": "focusDepth1", "TYPE": "float", "LABEL": "Focus plane A (world units)",
          "DEFAULT": 3.0, "MIN": 0.01, "MAX": 1000.0 },
        { "NAME": "focusDepth2", "TYPE": "float", "LABEL": "Focus plane B (world units)",
          "DEFAULT": 30.0, "MIN": 0.01, "MAX": 1000.0 },
        { "NAME": "focusRange", "TYPE": "float", "LABEL": "Focus range (world units, per plane)",
          "DEFAULT": 1.5, "MIN": 0.0, "MAX": 100.0 },
        { "NAME": "blurAmount", "TYPE": "float", "LABEL": "Max blur radius (pixels)",
          "DEFAULT": 14.0, "MIN": 0.0, "MAX": 80.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL_PREMULTIPLIED(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye = dh_linearizeDepth(rawD, camera.projection);
    float d1  = max(abs(eye - focusDepth1) - focusRange, 0.0);
    float d2  = max(abs(eye - focusDepth2) - focusRange, 0.0);
    float coc = min(d1, d2);
    float coc01 = clamp(coc / max(focusRange, 0.001), 0.0, 1.0);
    float radius = coc01 * blurAmount;

    if (radius < 0.5) { isf_FragColor = color; gl_FragDepth = rawD; return; }

    const int N = 16;
    vec2 texel = 1.0 / RENDERSIZE;
    vec4 acc = color;
    for (int i = 0; i < N; ++i) {
        float t = (float(i) + 0.5) / float(N);
        float r = sqrt(t);
        float a = float(i) * 2.39996323;
        acc += IMG_NORM_PIXEL_LOD0(inputImage, uv + vec2(cos(a), sin(a)) * r * radius * texel);
    }

    isf_FragColor = acc / float(N + 1);
    gl_FragDepth = rawD;
}
