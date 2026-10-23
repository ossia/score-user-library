/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Volumetric-feeling haze indexed by (uv, eyeDepth) so the fog appears to drift through the scene with 3D coherence rather than being a flat 2D overlay. Two octaves of value noise scrolled over TIME. The haze is painted over the input, so it also shows over a transparent sky.",
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

        { "NAME": "hazeColor", "TYPE": "color",
          "LABEL": "Haze colour",
          "DEFAULT": [0.8, 0.85, 0.9, 1.0] },

        { "NAME": "hazeDensity", "TYPE": "float",
          "LABEL": "Haze density",
          "DEFAULT": 0.6, "MIN": 0.0, "MAX": 2.0 },

        { "NAME": "noiseScale", "TYPE": "float",
          "LABEL": "Noise spatial scale",
          "DEFAULT": 4.0, "MIN": 0.1, "MAX": 40.0 },

        { "NAME": "noiseSpeed", "TYPE": "float",
          "LABEL": "Noise drift speed",
          "DEFAULT": 0.15, "MIN": 0.0, "MAX": 5.0 },

        { "NAME": "depthCurve", "TYPE": "float",
          "LABEL": "Depth curve (higher = haze concentrated far)",
          "DEFAULT": 1.5, "MIN": 0.1, "MAX": 8.0 },

        { "NAME": "farCutoff", "TYPE": "float",
          "LABEL": "Far cutoff (world units)",
          "DEFAULT": 60.0, "MIN": 0.1, "MAX": 10000.0 }
    ]
}*/

#include "depth_helpers.glsl"

// 3D-indexed noise by stacking two 2D value-noise samples at offset scales
// and summing. Cheap, no 3D texture needed.
float noise3d(vec3 p)
{
    float a = dh_valueNoise(p.xy + vec2(p.z * 0.7, p.z * 1.3));
    float b = dh_valueNoise(p.xz * 1.3 + vec2(p.y * 0.9, 0.0));
    return 0.5 * (a + b);
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    // Normalised depth in [0, 1] against a user far cutoff; sky clamps to 1.
    float depth01 = dh_normalizedEyeDepth(rawD, camera.projection, farCutoff);

    // Drifting 3D sample point: uv on XY, depth on Z, time shifts the slab.
    vec3 p = vec3(uv * noiseScale,
                  depth01 * noiseScale * 0.5 + TIME * noiseSpeed);

    float n = 0.6 * noise3d(p) + 0.4 * noise3d(p * 2.3 + vec3(17.0));

    // Depth-weighted so haze concentrates at distance; curve controls falloff.
    float depthWeight = pow(depth01, depthCurve);
    float coverage = clamp(n * hazeDensity * depthWeight, 0.0, 1.0);

    // The cleared sky has alpha 0: keep what this shader paints over it visible.
    isf_FragColor = dh_paintOver(color, hazeColor.rgb, coverage);
    gl_FragDepth = rawD;
}
