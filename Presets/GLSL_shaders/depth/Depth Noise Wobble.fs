/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Perturbs gl_FragDepth with 2D value noise, warping the depth map itself. Downstream depth-aware effects then 'see' a lumpy, undulating version of the scene — useful as a depth-chain noise injection for stacked effects.",
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
        { "NAME": "noiseScale", "TYPE": "float", "LABEL": "Noise scale",
          "DEFAULT": 6.0, "MIN": 0.1, "MAX": 80.0 },
        { "NAME": "noiseSpeed", "TYPE": "float", "LABEL": "Noise drift speed",
          "DEFAULT": 0.4, "MIN": 0.0, "MAX": 10.0 },
        { "NAME": "wobbleAmount", "TYPE": "float", "LABEL": "Wobble amount (world units)",
          "DEFAULT": 0.5, "MIN": 0.0, "MAX": 20.0 },
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
    float n = (dh_valueNoise(uv * noiseScale + TIME * noiseSpeed) - 0.5) * 2.0;
    float eyeOut = max(eye + n * wobbleAmount, 0.001);

    float outD = dh_encodeReverseZ(eyeOut, camera.projection);

    isf_FragColor = color;
    gl_FragDepth = outD;
}
