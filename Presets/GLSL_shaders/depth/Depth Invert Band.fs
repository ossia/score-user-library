/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Inverts pixel colours inside a moving slab of world-space depth. Set `scanSpeed` nonzero and the inversion band sweeps through the scene automatically (wrapping every `scanRange` beyond the band centre) — like a glitchy CT-scan readout.",
    "CATEGORIES": ["Post-process", "Slice"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "IS_DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "bandCenter", "TYPE": "float", "LABEL": "Band centre (world units)",
          "DEFAULT": 10.0, "MIN": 0.0, "MAX": 10000.0 },
        { "NAME": "bandWidth", "TYPE": "float", "LABEL": "Band width (world units)",
          "DEFAULT": 2.0, "MIN": 0.01, "MAX": 100.0 },
        { "NAME": "feather", "TYPE": "float", "LABEL": "Edge feather (world units)",
          "DEFAULT": 0.4, "MIN": 0.0, "MAX": 10.0 },
        { "NAME": "scanSpeed", "TYPE": "float", "LABEL": "Scan speed (world units / s; 0 = static)",
          "DEFAULT": 0.0, "MIN": -50.0, "MAX": 50.0 },
        { "NAME": "scanRange", "TYPE": "float", "LABEL": "Scan range (wraps every N world units)",
          "DEFAULT": 20.0, "MIN": 0.1, "MAX": 1000.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);

    float center = bandCenter + mod(TIME * scanSpeed, scanRange);
    float near = center - bandWidth * 0.5;
    float far  = center + bandWidth * 0.5;

    float mask = dh_slabMask(eye, near, far, feather);
    vec3 outRgb = mix(color.rgb, 1.0 - color.rgb, mask);

    isf_FragColor = vec4(outRgb, color.a);
    gl_FragDepth = rawD;
}
