/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Topographic banding: alternating colour stripes quantised to eye depth, like cartographic contour maps but filled. Each band alternates between `colorA` and `colorB` with optional luma modulation from the original scene. The bands are painted over the input, so a transparent sky is banded too.",
    "CATEGORIES": ["Post-process", "Slice"],

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
        { "NAME": "bandSpacing", "TYPE": "float", "LABEL": "Band spacing (world units)",
          "DEFAULT": 2.0, "MIN": 0.01, "MAX": 100.0 },
        { "NAME": "colorA", "TYPE": "color", "LABEL": "Band A colour",
          "DEFAULT": [0.2, 0.4, 0.8, 1.0] },
        { "NAME": "colorB", "TYPE": "color", "LABEL": "Band B colour",
          "DEFAULT": [0.8, 0.85, 0.95, 1.0] },
        { "NAME": "preserveLuma", "TYPE": "float", "LABEL": "Preserve luminance",
          "DEFAULT": 0.4, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "mixAmount", "TYPE": "float", "LABEL": "Mix (0 = scene, 1 = full bands)",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);

    float idx = floor(eye / max(bandSpacing, 0.001));
    bool even = mod(idx, 2.0) < 1.0;
    vec3 band = even ? colorA.rgb : colorB.rgb;

    float luma = dh_luma(color.rgb);
    band *= mix(1.0, luma * 2.0, preserveLuma);

    isf_FragColor = dh_paintOver(color, band, mixAmount);
    gl_FragDepth = rawD;
}
