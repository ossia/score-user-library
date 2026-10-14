/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Ink-wash style outlines via approximate Difference of Gaussians. Samples depth with a small cross and a larger ring, takes the difference relative to the local depth (0.1 = the ring is on average 10% deeper than the cross, so near and far silhouettes ink alike, whatever the scene's scale), and uses the result as a soft ink-bleed edge mask. Produces flowing, brushy outlines rather than hard pixel edges. Paper tint and ink are painted over the input, so a transparent background becomes paper too.",
    "CATEGORIES": ["Post-process", "Outlines"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "DEPTH": true,
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

        { "NAME": "inkColor", "TYPE": "color",
          "LABEL": "Ink colour",
          "DEFAULT": [0.05, 0.05, 0.08, 1.0] },
        { "NAME": "paperTint", "TYPE": "color",
          "LABEL": "Paper tint (lifted toward this)",
          "DEFAULT": [0.95, 0.92, 0.85, 1.0] },

        { "NAME": "innerRadius", "TYPE": "float",
          "LABEL": "Inner blur radius (pixels)",
          "DEFAULT": 1.0, "MIN": 0.5, "MAX": 8.0 },
        { "NAME": "outerRadius", "TYPE": "float",
          "LABEL": "Outer blur radius (pixels)",
          "DEFAULT": 4.0, "MIN": 1.0, "MAX": 24.0 },

        { "NAME": "inkThreshold", "TYPE": "float",
          "LABEL": "Ink threshold (relative depth jump, 0.1 = 10%)",
          "DEFAULT": 0.01, "MIN": 0.0, "MAX": 1.0 },

        { "NAME": "inkSoftness", "TYPE": "float",
          "LABEL": "Ink softness (relative depth jump)",
          "DEFAULT": 0.04, "MIN": 0.0, "MAX": 1.0 },

        { "NAME": "paperAmount", "TYPE": "float",
          "LABEL": "Paper tint amount",
          "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

// 4-sample box average of linearised depth at a given radius in pixels.
// Returns the mean. The 4 taps are N/S/E/W — cheap and rotationally
// symmetric enough for DoG purposes.
float avgLinearDepth(vec2 centerUV, vec2 texel, float radius, mat4 projection)
{
    float r0 = IMG_DEPTH_NORM_PIXEL(inputImage, centerUV);
    float rN = IMG_DEPTH_NORM_PIXEL(inputImage, centerUV + vec2(0.0,  texel.y * radius));
    float rS = IMG_DEPTH_NORM_PIXEL(inputImage, centerUV + vec2(0.0, -texel.y * radius));
    float rE = IMG_DEPTH_NORM_PIXEL(inputImage, centerUV + vec2( texel.x * radius, 0.0));
    float rW = IMG_DEPTH_NORM_PIXEL(inputImage, centerUV + vec2(-texel.x * radius, 0.0));

    float l0 = dh_linearizeDepth(r0, projection);
    float lN = dh_linearizeDepth(rN, projection);
    float lS = dh_linearizeDepth(rS, projection);
    float lE = dh_linearizeDepth(rE, projection);
    float lW = dh_linearizeDepth(rW, projection);

    return (l0 + lN + lS + lE + lW) * 0.2;
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    vec2 texel = 1.0 / RENDERSIZE;

    float inner = avgLinearDepth(uv, texel, innerRadius, camera.projection);
    float outer = avgLinearDepth(uv, texel, outerRadius, camera.projection);

    // DoG: where the broader sample is further behind the local average,
    // this fragment sits near a depth edge. Sign matters — we only want the
    // "peeking past an edge" direction, not the reverse.
    // Relative to the local depth (see "Edge detection on depth" in
    // depth_helpers.glsl).
    float diff = max(outer - inner, 0.0) / max(inner, DH_EPSILON);
    if (!(diff >= 0.0))
        diff = 0.0;
    float inkMask = dh_smoothstep(inkThreshold, inkThreshold + inkSoftness, diff);

    // Paper lift: gently push the whole scene toward the paper tint, then
    // ink over paper. Both are painted over the input.
    vec4 outColor = dh_paintOver(color, paperTint.rgb, paperAmount);
    isf_FragColor = dh_paintOver(outColor, inkColor.rgb, inkMask);
    gl_FragDepth = rawD;
}
