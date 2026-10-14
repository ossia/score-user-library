/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Tilt-shift / miniaturisation blur. Pixels within `focusRange` of `focusDepth` stay sharp; everything else blurs. Single-pass disc-sample blur at 8/16/24/32 taps. The blur works on premultiplied colour and alpha, so a blurred silhouette also spreads over a transparent background.",
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
        { "NAME": "focusDepth", "TYPE": "float", "LABEL": "Focus depth (world units)",
          "DEFAULT": 8.0, "MIN": 0.01, "MAX": 1000.0 },
        { "NAME": "focusRange", "TYPE": "float", "LABEL": "Focus range (world units, zero-blur zone)",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 100.0 },
        { "NAME": "blurAmount", "TYPE": "float", "LABEL": "Max blur radius (pixels)",
          "DEFAULT": 12.0, "MIN": 0.0, "MAX": 80.0 },
        { "NAME": "sampleCount", "TYPE": "long", "LABEL": "Disc samples",
          "VALUES": [8, 16, 24, 32], "LABELS": ["8", "16", "24", "32"], "DEFAULT": 16 }
    ]
}*/

#include "depth_helpers.glsl"

// Golden-angle disc pattern — uniform coverage with any sample count.
vec2 discSample(int i, int n)
{
    float r = sqrt((float(i) + 0.5) / float(n));
    float a = float(i) * 2.39996323;  // golden angle (radians)
    return vec2(cos(a), sin(a)) * r;
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL_PREMULTIPLIED(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye = dh_linearizeDepth(rawD, camera.projection);
    float coc = max(abs(eye - focusDepth) - focusRange, 0.0);
    // Normalise CoC to [0, 1] — saturate at one focal range away.
    float coc01 = clamp(coc / max(focusRange, 0.001), 0.0, 1.0);
    float radius = coc01 * blurAmount;

    if (radius < 0.5) {
        isf_FragColor = color;
        gl_FragDepth = rawD;
        return;
    }

    vec2 texel = 1.0 / RENDERSIZE;
    vec4 acc = color;
    float wsum = 1.0;
    for (int i = 0; i < sampleCount; ++i) {
        vec2 off = discSample(i, sampleCount) * radius * texel;
        vec4 s = IMG_NORM_PIXEL_LOD0(inputImage, uv + off);
        acc  += s;
        wsum += 1.0;
    }
    isf_FragColor = acc / wsum;
    gl_FragDepth = rawD;
}
