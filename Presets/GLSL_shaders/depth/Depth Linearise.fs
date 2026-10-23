/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Adapter shader: rewrites gl_FragDepth as normalised linear eye-depth in [0, 1], rather than ossia's default reverse-Z non-linear encoding. Use this at the head of a chain when feeding legacy shaders that assume `0 = near, 1 = far` linear. Downstream ossia depth helpers will misinterpret the output — this is for interop with non-ossia ISF assets only.",
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
        { "NAME": "farCutoff", "TYPE": "float", "LABEL": "Far cutoff (world units mapped to 1.0)",
          "DEFAULT": 50.0, "MIN": 0.1, "MAX": 10000.0 },
        { "NAME": "invert", "TYPE": "bool", "LABEL": "Invert (write 1 - normalised, matching reverse-Z sense)",
          "DEFAULT": false }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float d01 = dh_normalizedEyeDepth(rawD, camera.projection, farCutoff);
    float outD = invert ? (1.0 - d01) : d01;

    isf_FragColor = color;
    gl_FragDepth = outD;
}
