/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Morphological dilate / erode on depth. Dilate keeps the closest depth in a radius (fattens near objects, closes small far-side gaps). Erode keeps the farthest depth (thins near objects). Cheap way to simplify the depth silhouette before stacking other effects.",
    "CATEGORIES": ["Post-process", "Rewrite"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "mode", "TYPE": "long", "LABEL": "Operation",
          "VALUES": [0, 1], "LABELS": ["Dilate (near-fattens)", "Erode (near-thins)"], "DEFAULT": 0 },
        { "NAME": "radius", "TYPE": "float", "LABEL": "Radius (pixels)",
          "DEFAULT": 2.0, "MIN": 1.0, "MAX": 20.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    vec2 texel = 1.0 / RENDERSIZE;
    // 4-cardinal taps + centre. Reverse-Z: larger rawD == closer.
    float dC = rawD;
    float dN = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0,  texel.y * radius));
    float dS = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0, -texel.y * radius));
    float dE = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2( texel.x * radius, 0.0));
    float dW = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(-texel.x * radius, 0.0));

    float outD;
    if (mode == 0) {
        // Dilate near: keep max rawD == closest.
        outD = max(max(max(dC, dN), max(dS, dE)), dW);
    } else {
        // Erode near: keep min rawD == farthest.
        outD = min(min(min(dC, dN), min(dS, dE)), dW);
    }

    isf_FragColor = color;
    gl_FragDepth = outD;
}
