/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Depth-indexed wipe transition. As `progress` advances from 0 to 1, the scene fades to the target colour starting from either the near plane (front-to-back) or far plane (back-to-front). Perfect for musically-cued reveals. The target colour is painted over the input, so it also covers a transparent sky (which counts as the far end).",
    "CATEGORIES": ["Post-process", "Slice"],

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
        { "NAME": "progress", "TYPE": "float", "LABEL": "Wipe progress (0..1)",
          "DEFAULT": 0.3, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "softness", "TYPE": "float", "LABEL": "Edge softness (0..1 fraction of depth range)",
          "DEFAULT": 0.05, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "direction", "TYPE": "long", "LABEL": "Direction",
          "VALUES": [0, 1], "LABELS": ["Near → Far", "Far → Near"], "DEFAULT": 0 },
        { "NAME": "farCutoff", "TYPE": "float", "LABEL": "Far cutoff for depth normalisation (world units)",
          "DEFAULT": 50.0, "MIN": 0.1, "MAX": 10000.0 },
        { "NAME": "targetColor", "TYPE": "color", "LABEL": "Wipe-to colour",
          "DEFAULT": [0.0, 0.0, 0.0, 1.0] }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float d01 = dh_normalizedEyeDepth(rawD, camera.projection, farCutoff);
    float x   = (direction == 0) ? d01 : (1.0 - d01);

    // Reveal when progress >= x, with softness feather.
    float t = dh_smoothstep(progress - softness, progress + softness, x);
    // x < progress => t ≈ 0 => keep scene; x > progress => t ≈ 1 => target.
    isf_FragColor = dh_paintOver(color, targetColor.rgb, 1.0 - t);
    gl_FragDepth = rawD;
}
