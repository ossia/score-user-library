/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Three-colour depth banding. Near content gets tinted toward `nearColor`, mid toward `midColor`, far toward `farColor`, with smooth crossfades at band boundaries. Aggressive psychedelic look, tameable with the blend amount.",
    "CATEGORIES": ["Post-process", "Stylise"],

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
        { "NAME": "nearColor", "TYPE": "color", "LABEL": "Near tint",
          "DEFAULT": [1.0, 0.2, 0.3, 1.0] },
        { "NAME": "midColor", "TYPE": "color", "LABEL": "Mid tint",
          "DEFAULT": [0.3, 1.0, 0.4, 1.0] },
        { "NAME": "farColor", "TYPE": "color", "LABEL": "Far tint",
          "DEFAULT": [0.2, 0.4, 1.0, 1.0] },
        { "NAME": "midDepth", "TYPE": "float", "LABEL": "Mid band centre (world units)",
          "DEFAULT": 10.0, "MIN": 0.01, "MAX": 1000.0 },
        { "NAME": "farDepth", "TYPE": "float", "LABEL": "Far band centre (world units)",
          "DEFAULT": 40.0, "MIN": 0.01, "MAX": 10000.0 },
        { "NAME": "blend", "TYPE": "float", "LABEL": "Tint blend (0 = scene, 1 = full tint)",
          "DEFAULT": 0.8, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);

    // Smooth interpolate: near -> mid across [0, midDepth], mid -> far across [midDepth, farDepth].
    vec3 tint;
    if (eye < midDepth) {
        float t = clamp(eye / max(midDepth, 0.001), 0.0, 1.0);
        tint = mix(nearColor.rgb, midColor.rgb, t);
    } else {
        float t = clamp((eye - midDepth) / max(farDepth - midDepth, 0.001), 0.0, 1.0);
        tint = mix(midColor.rgb, farColor.rgb, t);
    }

    vec3 outRgb = mix(color.rgb, color.rgb * tint, blend);
    isf_FragColor = vec4(outRgb, color.a);
    gl_FragDepth = rawD;
}
