/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Retro CRT scanlines that roll through depth rather than across the screen — brightness is modulated by fract(eyeDepth * lineCount + time). The effect feels like light pulsing through the scene by distance.",
    "CATEGORIES": ["Post-process", "Stylise"],

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
        { "NAME": "lineCount", "TYPE": "float", "LABEL": "Lines per world unit",
          "DEFAULT": 0.5, "MIN": 0.01, "MAX": 20.0 },
        { "NAME": "lineSpeed", "TYPE": "float", "LABEL": "Line scroll speed",
          "DEFAULT": 1.0, "MIN": -10.0, "MAX": 10.0 },
        { "NAME": "lineStrength", "TYPE": "float", "LABEL": "Line darkening strength",
          "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "lineWidth", "TYPE": "float", "LABEL": "Line width (0..0.5 fraction)",
          "DEFAULT": 0.3, "MIN": 0.0, "MAX": 0.5 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    float eye   = dh_linearizeDepth(rawD, camera.projection);
    float phase = eye * lineCount + TIME * lineSpeed;
    float f     = abs(fract(phase) - 0.5) * 2.0;  // [0..1..0] triangle
    float line  = smoothstep(1.0 - lineWidth, 1.0, f);
    float mod_  = 1.0 - line * lineStrength;

    isf_FragColor = vec4(color.rgb * mod_, color.a);
    gl_FragDepth = rawD;
}
