/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Divides the scene into four depth layers (0..near, near..mid, mid..far, far..beyond) and replaces each layer with a flat colour modulated by the original luminance. A cel-shaded layer-cake look, perfect for infographic motion. The output is opaque: the empty background (a transparent sky) belongs to the farthest layer and is painted with Layer 4's colour, darkened by its zero luminance when Preserve original luminance is high.",
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
        { "NAME": "break1", "TYPE": "float", "LABEL": "Layer 1/2 break (world units)",
          "DEFAULT": 3.0, "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "break2", "TYPE": "float", "LABEL": "Layer 2/3 break (world units)",
          "DEFAULT": 10.0, "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "break3", "TYPE": "float", "LABEL": "Layer 3/4 break (world units)",
          "DEFAULT": 30.0, "MIN": 0.0, "MAX": 10000.0 },
        { "NAME": "layer1Color", "TYPE": "color", "LABEL": "Layer 1 (nearest)",
          "DEFAULT": [1.0, 0.8, 0.5, 1.0] },
        { "NAME": "layer2Color", "TYPE": "color", "LABEL": "Layer 2",
          "DEFAULT": [0.8, 0.3, 0.6, 1.0] },
        { "NAME": "layer3Color", "TYPE": "color", "LABEL": "Layer 3",
          "DEFAULT": [0.3, 0.4, 0.8, 1.0] },
        { "NAME": "layer4Color", "TYPE": "color", "LABEL": "Layer 4 (farthest)",
          "DEFAULT": [0.1, 0.1, 0.2, 1.0] },
        { "NAME": "preserveLuma", "TYPE": "float", "LABEL": "Preserve original luminance",
          "DEFAULT": 0.8, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);

    vec3 layer;
    if      (eye < break1) layer = layer1Color.rgb;
    else if (eye < break2) layer = layer2Color.rgb;
    else if (eye < break3) layer = layer3Color.rgb;
    else                    layer = layer4Color.rgb;

    float luma = dh_luma(color.rgb);
    vec3 modulated = layer * mix(1.0, luma * 2.0, preserveLuma);

    // Every pixel belongs to a layer, the cleared sky (alpha 0) to the last one.
    isf_FragColor = vec4(modulated, 1.0);
    gl_FragDepth = rawD;
}
