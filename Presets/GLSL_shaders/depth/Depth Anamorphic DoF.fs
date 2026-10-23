/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Anamorphic depth-of-field. Same depth-driven blur as Bokeh DoF but with independent X and Y radii so highlights smear into long horizontal streaks — the J.J. Abrams lens-flare look. The blur works on premultiplied colour and alpha, so a blurred silhouette also spreads over a transparent background.",
    "CATEGORIES": ["Post-process", "Focus"],
    "ALPHA": "premultiplied",

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
        { "NAME": "focusDepth", "TYPE": "float", "LABEL": "Focus depth (world units)",
          "DEFAULT": 8.0, "MIN": 0.01, "MAX": 1000.0 },
        { "NAME": "focusRange", "TYPE": "float", "LABEL": "Focus range (world units)",
          "DEFAULT": 1.5, "MIN": 0.0, "MAX": 100.0 },
        { "NAME": "blurX", "TYPE": "float", "LABEL": "Horizontal blur radius (pixels)",
          "DEFAULT": 30.0, "MIN": 0.0, "MAX": 150.0 },
        { "NAME": "blurY", "TYPE": "float", "LABEL": "Vertical blur radius (pixels)",
          "DEFAULT": 6.0,  "MIN": 0.0, "MAX": 150.0 },
        { "NAME": "streakTint", "TYPE": "color", "LABEL": "Streak tint (blue for classic anamorphic)",
          "DEFAULT": [0.55, 0.8, 1.0, 1.0] },
        { "NAME": "tintAmount", "TYPE": "float", "LABEL": "Streak tint amount",
          "DEFAULT": 0.25, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL_PREMULTIPLIED(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye = dh_linearizeDepth(rawD, camera.projection);
    float coc = max(abs(eye - focusDepth) - focusRange, 0.0);
    float coc01 = clamp(coc / max(focusRange, 0.001), 0.0, 1.0);

    if (coc01 < 0.01) { isf_FragColor = color; gl_FragDepth = rawD; return; }

    const int N = 24;
    vec2 texel = 1.0 / RENDERSIZE;
    vec4 acc = color;
    float wsum = 1.0;
    for (int i = 0; i < N; ++i) {
        float t = (float(i) + 0.5) / float(N);
        float r = sqrt(t);
        float a = float(i) * 2.39996323;
        vec2 off = vec2(cos(a) * blurX, sin(a) * blurY) * r * coc01 * texel;
        vec4 s = IMG_NORM_PIXEL_LOD0(inputImage, uv + off);
        float w = 1.0 + pow(dh_luma(s.rgb), 2.0) * 1.5;
        acc  += s * w;
        wsum += w;
    }

    vec4 blurred = acc / wsum;
    vec3 tinted  = mix(blurred.rgb, blurred.rgb * streakTint.rgb, tintAmount * coc01);

    isf_FragColor = vec4(tinted, blurred.a);
    gl_FragDepth = rawD;
}
