/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Pulsing edge outlines. Same depth-Sobel edge test as the clean outline shader, but the outline colour pulses with time at a user-controlled rate. Cheap cue-able accent for drops and transitions. Outlines are painted over the input, so they also show where a silhouette meets a transparent sky.",
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

        { "NAME": "flashColorA", "TYPE": "color",
          "LABEL": "Pulse colour A",
          "DEFAULT": [1.0, 0.2, 0.5, 1.0] },
        { "NAME": "flashColorB", "TYPE": "color",
          "LABEL": "Pulse colour B",
          "DEFAULT": [0.2, 0.8, 1.0, 1.0] },

        { "NAME": "pulseSpeed", "TYPE": "float",
          "LABEL": "Pulse speed (Hz)",
          "DEFAULT": 2.0, "MIN": 0.0, "MAX": 20.0 },

        { "NAME": "edgeThreshold", "TYPE": "float",
          "LABEL": "Edge threshold (relative depth jump, 0.1 = 10%)",
          "DEFAULT": 0.08, "MIN": 0.0, "MAX": 5.0 },
        { "NAME": "edgeSoftness", "TYPE": "float",
          "LABEL": "Edge softness (relative depth jump)",
          "DEFAULT": 0.04, "MIN": 0.0, "MAX": 2.0 },

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

    float nD[9];
    DH_GATHER_DEPTH_3X3(inputImage, uv, texel, nD);
    float edge = dh_depthEdgeSobel(nD, camera.projection);
    float edgeMask = dh_smoothstep(edgeThreshold, edgeThreshold + edgeSoftness, edge) * edgeOpacity;

    float t = 0.5 + 0.5 * sin(TIME * pulseSpeed * 6.28318);
    vec3 pulseColor = mix(flashColorA.rgb, flashColorB.rgb, t);

    vec3 dimmed = color.rgb * (1.0 - dimScene);
    isf_FragColor = dh_paintOver(vec4(dimmed, color.a), pulseColor, edgeMask);
    gl_FragDepth = rawD;
}
