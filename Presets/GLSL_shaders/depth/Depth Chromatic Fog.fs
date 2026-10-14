/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Per-channel fog: the red, green, and blue channels each fog at different depths, producing a soft rainbow dispersion that intensifies with distance. Classic psychedelic haze look. The fog is painted over the input, so it also shows over a transparent sky.",
    "CATEGORIES": ["Post-process", "Atmosphere"],

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

        { "NAME": "fogColor", "TYPE": "color",
          "LABEL": "Fog target colour (per-channel ramps toward this)",
          "DEFAULT": [1.0, 1.0, 1.0, 1.0] },

        { "NAME": "redStart", "TYPE": "float",
          "LABEL": "Red channel fog start (world units)",
          "DEFAULT": 4.0, "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "redEnd", "TYPE": "float",
          "LABEL": "Red channel fog end (world units)",
          "DEFAULT": 40.0, "MIN": 0.1, "MAX": 10000.0 },

        { "NAME": "greenStart", "TYPE": "float",
          "LABEL": "Green channel fog start (world units)",
          "DEFAULT": 8.0, "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "greenEnd", "TYPE": "float",
          "LABEL": "Green channel fog end (world units)",
          "DEFAULT": 50.0, "MIN": 0.1, "MAX": 10000.0 },

        { "NAME": "blueStart", "TYPE": "float",
          "LABEL": "Blue channel fog start (world units)",
          "DEFAULT": 12.0, "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "blueEnd", "TYPE": "float",
          "LABEL": "Blue channel fog end (world units)",
          "DEFAULT": 60.0, "MIN": 0.1, "MAX": 10000.0 },

        { "NAME": "fogAmount", "TYPE": "float",
          "LABEL": "Overall fog amount",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye = dh_linearizeDepth(rawD, camera.projection);

    // Three independent fog ramps, one per channel.
    float fR = dh_fogFactor(eye, redStart,   redEnd)   * fogAmount;
    float fG = dh_fogFactor(eye, greenStart, greenEnd) * fogAmount;
    float fB = dh_fogFactor(eye, blueStart,  blueEnd)  * fogAmount;

    // The cleared sky has alpha 0: keep what this shader paints over it visible.
    isf_FragColor = dh_paintOver(color, fogColor.rgb, vec3(fR, fG, fB));
    gl_FragDepth = rawD;
}
