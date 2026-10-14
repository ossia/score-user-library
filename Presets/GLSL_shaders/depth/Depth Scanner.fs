/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Sci-fi depth scanner: a bright pulse of colour sweeps along the depth axis. Pixels whose eye depth falls within the pulse light up. Loops automatically — hook `lineSpeed` to a beat for a synced pulse.",
    "CATEGORIES": ["Post-process", "Slice"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "lineSpeed", "TYPE": "float", "LABEL": "Scanner speed (world units / s)",
          "DEFAULT": 5.0, "MIN": -50.0, "MAX": 50.0 },
        { "NAME": "scanRange", "TYPE": "float", "LABEL": "Scanner range (wrap length)",
          "DEFAULT": 30.0, "MIN": 0.1, "MAX": 1000.0 },
        { "NAME": "pulseWidth", "TYPE": "float", "LABEL": "Pulse width (world units)",
          "DEFAULT": 0.5, "MIN": 0.01, "MAX": 50.0 },
        { "NAME": "pulseColor", "TYPE": "color", "LABEL": "Scanner colour",
          "DEFAULT": [0.2, 1.0, 0.5, 1.0] },
        { "NAME": "pulseIntensity", "TYPE": "float", "LABEL": "Pulse brightness",
          "DEFAULT": 2.0, "MIN": 0.0, "MAX": 10.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    if (dh_isSky(rawD)) {
        isf_FragColor = color; gl_FragDepth = rawD; return;
    }

    float eye = dh_linearizeDepth(rawD, camera.projection);
    float center = mod(TIME * lineSpeed, scanRange);
    float d = abs(eye - center);
    // Smooth bell within pulseWidth, zero beyond.
    float pulse = exp(-pow(d / max(pulseWidth, 0.001), 2.0));

    vec3 outRgb = color.rgb + pulseColor.rgb * pulse * pulseIntensity;
    isf_FragColor = vec4(outRgb, color.a);
    gl_FragDepth = rawD;
}
