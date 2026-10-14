/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Roberts-cross edge detection on scene depth. Cheaper and sharper than Sobel at 1px, ideal for crisp cel-shade outlines. 2x2 diagonal depth differences on linearised eye depth, thresholded as a relative depth jump (0.1 = 10%). Outlines are painted over the input, so they also show where a silhouette meets a transparent sky.",
    "CATEGORIES": ["Post-process", "Outlines"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "DEPTH": true,
          "LABEL": "Scene color + depth" },

        {
            "NAME": "camera", "TYPE": "uniform",
            "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" }
            ]
        },

        { "NAME": "edgeColor", "TYPE": "color",
          "LABEL": "Outline colour",
          "DEFAULT": [1.0, 1.0, 1.0, 1.0] },
        { "NAME": "edgeThreshold", "TYPE": "float",
          "LABEL": "Edge threshold (relative depth jump, 0.1 = 10%)",
          "DEFAULT": 0.05, "MIN": 0.0, "MAX": 5.0 },
        { "NAME": "edgeSoftness", "TYPE": "float",
          "LABEL": "Edge softness (relative depth jump)",
          "DEFAULT": 0.03, "MIN": 0.0, "MAX": 2.0 },
        { "NAME": "edgeOpacity", "TYPE": "float",
          "LABEL": "Outline opacity",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "dimScene", "TYPE": "float",
          "LABEL": "Scene dim (0 = normal, 1 = black)",
          "DEFAULT": 0.0, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    // Roberts cross needs four samples in a 2x2 window. The ISF depth
    // macro must see the input identifier textually, so the gather is here.
    vec2 texel = 1.0 / RENDERSIZE;
    float dAA = rawD;  // uv               (this pixel)
    float dBB = IMG_DEPTH_NORM_PIXEL(inputImage, uv + texel);
    float dBA = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(texel.x, 0.0));
    float dAB = IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0, texel.y));

    float edge = dh_depthEdgeRoberts(dAA, dBB, dBA, dAB, camera.projection);

    float edgeMask = dh_smoothstep(edgeThreshold,
                                   edgeThreshold + edgeSoftness,
                                   edge) * edgeOpacity;

    vec3 dimmed = color.rgb * (1.0 - dimScene);
    isf_FragColor = dh_paintOver(vec4(dimmed, color.a), edgeColor.rgb, edgeMask);
    gl_FragDepth = rawD;
}
