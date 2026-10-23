/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Depth-based linear fog. Mixes the scene toward a fog colour based on view-space eye depth, derived from the camera projection matrix. Sky fragments can be fogged or passed through. The fog is painted over the input, so the transparent sky of a scene gets fog at the fog's own opacity.",
    "CATEGORIES": ["Post-process", "Atmosphere"],

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

        { "NAME": "fogColor",   "TYPE": "color",
          "LABEL": "Fog colour",
          "DEFAULT": [0.7, 0.8, 0.9, 1.0] },
        { "NAME": "fogStart",   "TYPE": "float",
          "LABEL": "Fog start (world units)",
          "DEFAULT": 5.0, "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "fogEnd",     "TYPE": "float",
          "LABEL": "Fog end (world units)",
          "DEFAULT": 50.0, "MIN": 0.1, "MAX": 10000.0 },
        { "NAME": "fogAmount",  "TYPE": "float",
          "LABEL": "Fog amount",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "fogSky",     "TYPE": "bool",
          "LABEL": "Fog the sky",
          "DEFAULT": true }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    // Eye depth in world units, from the camera projection matrix.
    float eye = dh_linearizeDepth(rawD, camera.projection);

    // Linear interpolation between fogStart and fogEnd, in eye-depth units
    // so the user thinks in scene-scale rather than normalised [0,1].
    // GL_LINEAR fog (OpenGL 1.x spec, 3.10 "Fog"): f = (end - z) / (end - start),
    // clamped. dh_smoothstep is that clamped linear ramp (dh_fogFactor is a
    // smoothstep, which is not what "linear fog" means).
    float fog = dh_smoothstep(fogStart, fogEnd, eye) * fogAmount;

    // Optionally skip fogging on sky (lets a punchy backdrop show through).
    if (!fogSky && dh_isSky(rawD)) {
        fog = 0.0;
    }

    // The cleared sky is transparent (alpha 0): keeping color.a would fog the
    // sky's RGB but leave it invisible. Fog is painted over it at `fog`.
    isf_FragColor = dh_paintOver(color, fogColor.rgb, fog);
    gl_FragDepth = rawD;  // forward depth for downstream depth-aware filters
}
