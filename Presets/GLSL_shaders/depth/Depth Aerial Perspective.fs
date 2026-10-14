/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Aerial perspective. Desaturates and blue-shifts distant pixels, simulating the atmospheric scattering that makes mountains look blue-grey. Cheaper and subtler than full fog; pairs well with any other Atmosphere shader. The tint is painted over the input, so a transparent sky gets it at the tint's own opacity.",
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

        { "NAME": "fogStart", "TYPE": "float",
          "LABEL": "Effect start (world units)",
          "DEFAULT": 5.0,  "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "fogEnd", "TYPE": "float",
          "LABEL": "Effect end (world units)",
          "DEFAULT": 80.0, "MIN": 0.1, "MAX": 10000.0 },

        { "NAME": "desatAmount", "TYPE": "float",
          "LABEL": "Desaturation amount",
          "DEFAULT": 0.6, "MIN": 0.0, "MAX": 1.0 },

        { "NAME": "blueShift", "TYPE": "float",
          "LABEL": "Blue shift amount",
          "DEFAULT": 0.35, "MIN": 0.0, "MAX": 1.0 },

        { "NAME": "atmosphereColor", "TYPE": "color",
          "LABEL": "Far-distance atmosphere tint",
          "DEFAULT": [0.55, 0.7, 0.95, 1.0] }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye = dh_linearizeDepth(rawD, camera.projection);
    float t   = dh_smoothstep(fogStart, fogEnd, eye);

    // Desaturate toward luminance.
    float luma = dh_luma(color.rgb);
    vec3  desat = mix(color.rgb, vec3(luma), t * desatAmount);

    // Blue-shift toward the atmosphere colour (not replacing — tinting).
    // The cleared sky has alpha 0: keep what this shader paints over it visible.
    isf_FragColor = dh_paintOver(vec4(desat, color.a), atmosphereColor.rgb, t * blueShift);
    gl_FragDepth = rawD;
}
