/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Combined depth + luminance edge detection. Runs Sobel on both the scene depth and the scene luminance, then takes the weighted max. Catches edges that depth misses (internal texture detail) AND that colour misses (same-coloured objects in front of each other). Outlines are painted over the input, so they also show where a silhouette meets a transparent sky.",
    "CATEGORIES": ["Post-process", "Outlines"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "IS_DEPTH": true,
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

        { "NAME": "depthWeight", "TYPE": "float",
          "LABEL": "Depth-edge weight",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 4.0 },
        { "NAME": "colorWeight", "TYPE": "float",
          "LABEL": "Colour-edge weight",
          "DEFAULT": 0.5, "MIN": 0.0, "MAX": 4.0 },

        { "NAME": "depthThreshold", "TYPE": "float",
          "LABEL": "Depth edge threshold (relative depth jump, 0.1 = 10%)",
          "DEFAULT": 0.1, "MIN": 0.0, "MAX": 5.0 },
        { "NAME": "colorThreshold", "TYPE": "float",
          "LABEL": "Colour edge threshold (luma)",
          "DEFAULT": 0.15, "MIN": 0.0, "MAX": 2.0 },

        { "NAME": "edgeSoftness", "TYPE": "float",
          "LABEL": "Edge softness",
          "DEFAULT": 0.05, "MIN": 0.0, "MAX": 2.0 },
        { "NAME": "edgeOpacity", "TYPE": "float",
          "LABEL": "Outline opacity",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "dimScene", "TYPE": "float",
          "LABEL": "Scene dim",
          "DEFAULT": 0.0, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    vec2 texel = 1.0 / RENDERSIZE;

    // Two 3x3 gathers — one luma, one depth. The macros hide the loop so
    // this stays readable even with two neighbourhoods in flight.
    float lumaN[9];
    DH_GATHER_LUMA_3X3(inputImage, uv, texel, lumaN);

    float rawN[9];
    DH_GATHER_DEPTH_3X3(inputImage, uv, texel, rawN);

    float colorEdge = dh_sobelMag(lumaN);
    float depthEdge = dh_depthEdgeSobel(rawN, camera.projection);

    // Separate thresholds then weighted max, so the user can tune each
    // channel's sensitivity independently.
    float colorMask = dh_smoothstep(colorThreshold, colorThreshold + edgeSoftness, colorEdge);
    float depthMask = dh_smoothstep(depthThreshold, depthThreshold + edgeSoftness, depthEdge);
    float edgeMask  = max(colorMask * colorWeight, depthMask * depthWeight);
    edgeMask = clamp(edgeMask, 0.0, 1.0) * edgeOpacity;

    vec3 dimmed = color.rgb * (1.0 - dimScene);
    isf_FragColor = dh_paintOver(vec4(dimmed, color.a), edgeColor.rgb, edgeMask);
    gl_FragDepth = rawD;
}
