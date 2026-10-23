/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Perturbs gl_FragDepth with a sum-of-sines pattern. Unlike Noise Wobble (which is stochastic), this gives a periodic, structured distortion — ripples, waves, corrugations. Independent X/Y frequencies and a time phase let you dial between standing waves and travelling ripples.",
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
        { "NAME": "amplitude", "TYPE": "float", "LABEL": "Amplitude (world units)",
          "DEFAULT": 0.3, "MIN": 0.0, "MAX": 20.0 },
        { "NAME": "freqX", "TYPE": "float", "LABEL": "Frequency X",
          "DEFAULT": 6.0, "MIN": 0.0, "MAX": 80.0 },
        { "NAME": "freqY", "TYPE": "float", "LABEL": "Frequency Y",
          "DEFAULT": 4.0, "MIN": 0.0, "MAX": 80.0 },
        { "NAME": "phaseSpeed", "TYPE": "float", "LABEL": "Phase speed (rad/s)",
          "DEFAULT": 1.5, "MIN": -20.0, "MAX": 20.0 },
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

    // Sum two orthogonal sines plus a diagonal beat — richer than either alone.
    float phase = TIME * phaseSpeed;
    float s = sin(uv.x * freqX * DH_TWO_PI + phase)
            + sin(uv.y * freqY * DH_TWO_PI + phase * 0.7)
            + 0.5 * sin((uv.x + uv.y) * (freqX + freqY) * 0.5 * DH_TWO_PI - phase);
    float eyeOut = max(eye + s * amplitude * 0.333, 0.001);

    float outD = dh_encodeReverseZ(eyeOut, camera.projection);

    isf_FragColor = color;
    gl_FragDepth = outD;
}
