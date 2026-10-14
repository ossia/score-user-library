/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Topographic contour lines at equal depth intervals. Draws a thin band wherever linearised eye depth crosses a multiple of the band spacing, producing an elevation-map overlay on top of the scene. Cartographic / schematic look.",
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

        { "NAME": "bandSpacing", "TYPE": "float",
          "LABEL": "Band spacing (world units)",
          "DEFAULT": 2.0, "MIN": 0.01, "MAX": 100.0 },

        { "NAME": "bandThickness", "TYPE": "float",
          "LABEL": "Band thickness (0..1 fraction of spacing)",
          "DEFAULT": 0.08, "MIN": 0.001, "MAX": 0.5 },

        { "NAME": "bandColor", "TYPE": "color",
          "LABEL": "Band colour",
          "DEFAULT": [1.0, 1.0, 1.0, 1.0] },

        { "NAME": "bandOpacity", "TYPE": "float",
          "LABEL": "Band opacity",
          "DEFAULT": 0.85, "MIN": 0.0, "MAX": 1.0 },

        { "NAME": "majorEvery", "TYPE": "long",
          "LABEL": "Major band every N (0 = disable major)",
          "MIN": 0, "MAX": 32, "DEFAULT": 5 },

        { "NAME": "majorColor", "TYPE": "color",
          "LABEL": "Major band colour",
          "DEFAULT": [1.0, 0.8, 0.2, 1.0] },

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

    vec4 outColor = vec4(color.rgb * (1.0 - dimScene), color.a);

    if (!dh_isSky(rawD))
    {
        float eye = dh_linearizeDepth(rawD, camera.projection);

        // Distance into the current band, in [0, 1].
        float bandIdx   = eye / bandSpacing;
        float bandFract = fract(bandIdx);

        // Symmetric distance from centre of band, then invert so "edge" == 1.
        float dist = abs(bandFract - 0.5) * 2.0;  // [0, 1]
        float lineStrength = smoothstep(1.0 - bandThickness, 1.0, dist);

        // Anti-aliasing: scale thickness by the depth derivative so bands
        // don't alias into thin pixels when the camera is close or steep.
        float dE = fwidth(eye) / bandSpacing;
        lineStrength *= clamp(1.0 / max(dE * 40.0, 0.01), 0.0, 1.0);

        vec4 lineColor = bandColor;

        // Major bands every N-th, if enabled.
        if (majorEvery > 0) {
            int bi = int(floor(bandIdx));
            if (bi % majorEvery == 0) {
                lineColor = majorColor;
            }
        }

        outColor = dh_paintOver(outColor, lineColor.rgb, lineStrength * bandOpacity);
    }

    isf_FragColor = outColor;
    gl_FragDepth = rawD;
}
