/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Hand-drawn-feeling outlines. Same Sobel depth-edge test as the clean outline shader, but the sample positions are perturbed by low-frequency noise so the outline wobbles over time. Perfect for Aardman / indie-game aesthetics. Outlines are painted over the input, so they also show where a silhouette meets a transparent sky.",
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
          "DEFAULT": [0.05, 0.05, 0.05, 1.0] },

        { "NAME": "edgeThreshold", "TYPE": "float",
          "LABEL": "Edge threshold (relative depth jump, 0.1 = 10%)",
          "DEFAULT": 0.05, "MIN": 0.0, "MAX": 5.0 },
        { "NAME": "edgeSoftness", "TYPE": "float",
          "LABEL": "Edge softness (relative depth jump)",
          "DEFAULT": 0.03, "MIN": 0.0, "MAX": 2.0 },

        { "NAME": "wobbleAmount", "TYPE": "float",
          "LABEL": "Wobble amount (pixels)",
          "DEFAULT": 2.0, "MIN": 0.0, "MAX": 20.0 },

        { "NAME": "wobbleScale", "TYPE": "float",
          "LABEL": "Wobble spatial scale",
          "DEFAULT": 12.0, "MIN": 1.0, "MAX": 80.0 },

        { "NAME": "wobbleSpeed", "TYPE": "float",
          "LABEL": "Wobble speed",
          "DEFAULT": 1.5, "MIN": 0.0, "MAX": 20.0 },

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

    // Two noise octaves at different phases give a 2D displacement vector.
    // Time-quantised so the wobble steps on an integer frame count, which
    // gives a stopmo / claymation "every couple of frames it jumps" feel.
    float tq = floor(TIME * wobbleSpeed * 8.0) / 8.0;
    vec2 noisePos = uv * wobbleScale;
    float nx = dh_valueNoise(noisePos + vec2(tq, 0.0));
    float ny = dh_valueNoise(noisePos + vec2(0.0, tq) + 37.0);
    vec2 wobble = (vec2(nx, ny) - 0.5) * wobbleAmount * texel;

    // Sample the 3x3 neighbourhood at the WOBBLED centre.
    float nD[9];
    DH_GATHER_DEPTH_3X3(inputImage, uv + wobble, texel, nD);
    float edge = dh_depthEdgeSobel(nD, camera.projection);

    float edgeMask = dh_smoothstep(edgeThreshold, edgeThreshold + edgeSoftness, edge) * edgeOpacity;

    vec3 dimmed = color.rgb * (1.0 - dimScene);
    isf_FragColor = dh_paintOver(vec4(dimmed, color.a), edgeColor.rgb, edgeMask);
    gl_FragDepth = rawD;
}
