/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Cavity shading: darkens concavities (cracks, crevices, inner corners) using the sign of the depth Laplacian. Bolder and more stylised than micro-AO; great for making rocks and skulls feel carved.",
    "CATEGORIES": ["Post-process", "Lighting"],

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
        { "NAME": "radius", "TYPE": "float", "LABEL": "Cavity radius (pixels)",
          "DEFAULT": 4.0, "MIN": 1.0, "MAX": 20.0 },
        { "NAME": "cavityStrength", "TYPE": "float", "LABEL": "Cavity darkening strength",
          "DEFAULT": 2.5, "MIN": 0.0, "MAX": 10.0 },
        { "NAME": "cavityColor", "TYPE": "color", "LABEL": "Cavity tint",
          "DEFAULT": [0.0, 0.0, 0.0, 1.0] }
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

    vec2 texel = 1.0 / RENDERSIZE;
    float l0 = dh_linearizeDepth(rawD, camera.projection);
    float lN = dh_linearizeDepth(IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0,  texel.y * radius)), camera.projection);
    float lS = dh_linearizeDepth(IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(0.0, -texel.y * radius)), camera.projection);
    float lE = dh_linearizeDepth(IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2( texel.x * radius, 0.0)), camera.projection);
    float lW = dh_linearizeDepth(IMG_DEPTH_NORM_PIXEL(inputImage, uv + vec2(-texel.x * radius, 0.0)), camera.projection);

    // Laplacian (relative to the centre depth). lap < 0: this pixel is
    // BEHIND its neighbours -- a crevice / inner corner -- which is what gets
    // darkened. Neighbours more than 5% of the depth away are another surface
    // (a silhouette), not a cavity; without this range check every background
    // pixel next to a nearer object got a dark halo.
    float d[4];
    d[0] = lN - l0; d[1] = lS - l0; d[2] = lE - l0; d[3] = lW - l0;
    // Pairs (N,S) and (E,W) are kept or dropped TOGETHER: dropping one tap
    // of a pair leaves a one-sided first difference, which reads the limb
    // of every convex object as a crease.
    float lap = 0.0, n = 0.0;
    for (int i = 0; i < 4; i += 2) {
        float lim = 0.05 * l0;
        if (abs(d[i]) < lim && abs(d[i + 1]) < lim) { lap += d[i] + d[i + 1]; n += 1.0; }
    }
    lap = (n > 0.0) ? lap * 2.0 / n / max(l0, DH_EPSILON) : 0.0;
    float cavity = clamp(-lap * cavityStrength * 100.0, 0.0, 1.0);

    vec3 outRgb = mix(color.rgb, cavityColor.rgb, cavity);

    isf_FragColor = vec4(outRgb, color.a);
    gl_FragDepth = rawD;
}
