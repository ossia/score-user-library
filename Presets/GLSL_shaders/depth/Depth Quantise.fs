/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Depth rewriter: quantises gl_FragDepth into discrete steps, forwarding the scene colour unchanged. Downstream depth-aware filters (fog, DoF, SSAO) then see a blocky, LEGO-stepped geometry. Steps are equal slices of linear eye depth between the camera and `farCutoff` (world units), re-encoded to reverse-Z.",
    "CATEGORIES": ["Post-process", "Rewrite"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "IS_DEPTH": true,
          "LABEL": "Scene color + depth" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "farCutoff", "TYPE": "float", "LABEL": "Far cutoff (world units, last step)",
          "DEFAULT": 50.0, "MIN": 0.1, "MAX": 10000.0 },
        { "NAME": "steps", "TYPE": "long",
          "LABEL": "Depth steps",
          "VALUES": [4, 8, 16, 32, 64, 128],
          "LABELS": ["4", "8", "16", "32", "64", "128"],
          "DEFAULT": 16 },

        { "NAME": "mixAmount", "TYPE": "float",
          "LABEL": "Effect amount (0 = bypass, 1 = fully stepped)",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 },

        { "NAME": "passThroughSky", "TYPE": "bool",
          "LABEL": "Leave sky depth untouched",
          "DEFAULT": true }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float stepped = rawD;
    if (!(passThroughSky && dh_isSky(rawD))) {
        // Quantise in linear eye depth (centre of each slice), then encode
        // back to the reverse-Z value downstream shaders expect.
        float d01 = dh_normalizedEyeDepth(rawD, camera.projection, farCutoff);
        float q01 = (floor(d01 * float(steps)) + 0.5) / float(steps);
        stepped = dh_encodeReverseZ(q01 * farCutoff, camera.projection);
    }

    float outD = mix(rawD, stepped, mixAmount);

    // Rewrite category: forward colour unchanged, emit transformed depth.
    isf_FragColor = color;
    gl_FragDepth = outD;
}
