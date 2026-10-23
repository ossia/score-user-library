/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Flips gl_FragDepth around a centre depth in world units. Near objects become 'far', far objects become 'near' — downstream fog / DoF / slice effects see a scene turned inside-out. Good for unsettling visuals or experimental depth pipelines.",
    "CATEGORIES": ["Post-process", "Rewrite"],

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
        { "NAME": "pivotDepth", "TYPE": "float", "LABEL": "Pivot depth (world units)",
          "DEFAULT": 15.0, "MIN": 0.1, "MAX": 10000.0 },
        { "NAME": "mixAmount", "TYPE": "float", "LABEL": "Mix (0 = bypass, 1 = fully inverted)",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "skyPassthrough", "TYPE": "bool", "LABEL": "Leave sky untouched",
          "DEFAULT": true }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    if (skyPassthrough && dh_isSky(rawD)) {
        isf_FragColor = color; gl_FragDepth = rawD; return;
    }

    float eye = dh_linearizeDepth(rawD, camera.projection);
    float flipped = max(2.0 * pivotDepth - eye, 0.001);
    float eyeOut  = mix(eye, flipped, mixAmount);

    float outD = dh_encodeReverseZ(eyeOut, camera.projection);

    isf_FragColor = color;
    gl_FragDepth = outD;
}
