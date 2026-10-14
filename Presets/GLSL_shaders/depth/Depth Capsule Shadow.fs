/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Capsule shadow: darkens fragments near a user-placed world-space line segment. Useful for faking a character's contact shadow on a floor, or for cheap stylised shadow hits from abstract primitives.",
    "CATEGORIES": ["Post-process", "Lighting"],

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
        { "NAME": "capsuleStart", "TYPE": "point3D", "LABEL": "Capsule start (world units)",
          "DEFAULT": [0.0, 2.0, 0.0] },
        { "NAME": "capsuleEnd", "TYPE": "point3D", "LABEL": "Capsule end (world units)",
          "DEFAULT": [0.0, 4.0, 0.0] },
        { "NAME": "capsuleRadius", "TYPE": "float", "LABEL": "Capsule radius (world units)",
          "DEFAULT": 1.0, "MIN": 0.01, "MAX": 20.0 },
        { "NAME": "shadowOpacity", "TYPE": "float", "LABEL": "Shadow opacity",
          "DEFAULT": 0.6, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "shadowColor", "TYPE": "color", "LABEL": "Shadow tint",
          "DEFAULT": [0.05, 0.02, 0.1, 1.0] }
    ]
}*/

#include "depth_helpers.glsl"

// Distance from point p to line segment (a, b).
float distPointSegment(vec3 p, vec3 a, vec3 b)
{
    vec3 ab = b - a;
    float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 0.0001), 0.0, 1.0);
    return length(p - (a + ab * t));
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    if (dh_isSky(rawD)) {
        isf_FragColor = color; gl_FragDepth = rawD; return;
    }

    mat4 invVP = inverse(camera.viewProjection);
    vec3 worldPos = dh_worldPosFromDepth(uv, rawD, invVP);

    float d = distPointSegment(worldPos, capsuleStart, capsuleEnd);
    float mask = 1.0 - smoothstep(0.0, capsuleRadius, d);
    float shadow = mask * shadowOpacity;

    vec3 outRgb = mix(color.rgb, shadowColor.rgb, shadow);

    isf_FragColor = vec4(outRgb, color.a);
    gl_FragDepth = rawD;
}
