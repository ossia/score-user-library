/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Hitchcock dolly-zoom post effect. Re-projects UVs radially from the warp centre based on distance from the focus plane, which stays still. Positive warpAmount shrinks what lies behind the focus plane toward the centre (the background recedes) and enlarges what lies in front; negative does the opposite (the background looms). Uncanny, unsettling, perfect for suspense builds. Cheap: each pixel uses its own depth, so silhouettes tear at strong settings; the empty sky is left as it is.",
    "CATEGORIES": ["Post-process", "Focus"],

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
        { "NAME": "focusDepth", "TYPE": "float", "LABEL": "Focus depth (world units, the still-point)",
          "DEFAULT": 8.0, "MIN": 0.01, "MAX": 1000.0 },
        { "NAME": "warpAmount", "TYPE": "float", "LABEL": "Warp amount (negative = pull in, positive = push out)",
          "DEFAULT": 0.2, "MIN": -1.0, "MAX": 1.0 },
        { "NAME": "center", "TYPE": "point2D", "LABEL": "Warp centre",
          "DEFAULT": [0.5, 0.5], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    // The sky has no depth to warp by (its far-plane depth would throw the
    // sample far off screen).
    if (dh_isSky(rawD)) {
        isf_FragColor = IMG_NORM_PIXEL(inputImage, uv);
        gl_FragDepth = rawD;
        return;
    }

    // We want to pick, for each output pixel, what input pixel the warp
    // should pull from. Cheap approximation: use this output pixel's depth
    // to choose the warp factor. (A correct implementation would iterate.)
    float eye = dh_linearizeDepth(rawD, camera.projection);
    float signedDist = eye - focusDepth;
    // Normalise over a reasonable scene span.
    float k = signedDist / max(focusDepth, 0.001);

    vec2 sampleUV = center + (uv - center) * (1.0 + warpAmount * k);
    vec4 color = IMG_NORM_PIXEL(inputImage, sampleUV);

    isf_FragColor = color;
    gl_FragDepth = rawD;
}
