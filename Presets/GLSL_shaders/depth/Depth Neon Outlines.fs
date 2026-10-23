/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Neon/Tron-style glowing outlines. Runs Sobel on depth, then convolves the edge mask with a small radial kernel to produce a soft glow bleed, then composites glow + hard edge back over the scene. Single-pass, but expensive (8 extra 3x3 depth gathers per pixel). Glow and edges are painted over the input, so they also show over a transparent sky.",
    "CATEGORIES": ["Post-process", "Outlines"],

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

        { "NAME": "edgeColor", "TYPE": "color",
          "LABEL": "Edge core colour",
          "DEFAULT": [1.0, 0.9, 0.95, 1.0] },
        { "NAME": "glowColor", "TYPE": "color",
          "LABEL": "Glow halo colour",
          "DEFAULT": [1.0, 0.1, 0.6, 1.0] },

        { "NAME": "edgeThreshold", "TYPE": "float",
          "LABEL": "Edge threshold (relative depth jump, 0.1 = 10%)",
          "DEFAULT": 0.08, "MIN": 0.0, "MAX": 5.0 },
        { "NAME": "edgeSoftness", "TYPE": "float",
          "LABEL": "Edge softness (relative depth jump)",
          "DEFAULT": 0.04, "MIN": 0.0, "MAX": 2.0 },

        { "NAME": "glowRadius", "TYPE": "long",
          "LABEL": "Glow radius (pixels)",
          "VALUES": [2, 3, 4, 6, 8, 12],
          "LABELS": ["2", "3", "4", "6", "8", "12"],
          "DEFAULT": 2 },

        { "NAME": "glowIntensity", "TYPE": "float",
          "LABEL": "Glow intensity",
          "DEFAULT": 1.5, "MIN": 0.0, "MAX": 5.0 },

        { "NAME": "dimScene", "TYPE": "float",
          "LABEL": "Scene dim",
          "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    vec2 texel = 1.0 / RENDERSIZE;

    // Core edge at this pixel.
    float nD[9];
    DH_GATHER_DEPTH_3X3(inputImage, uv, texel, nD);
    float coreEdge = dh_depthEdgeSobel(nD, camera.projection);
    float coreMask = dh_smoothstep(edgeThreshold, edgeThreshold + edgeSoftness, coreEdge);

    // Glow mask: sample the same edge test at 8 angular offsets around the
    // pixel and take the max, producing a cheap dilation. Weight by a cosine
    // falloff vs radius for a soft halo.
    float glowMask = coreMask;
    float radius = float(glowRadius);
    const int STEPS = 8;
    for (int i = 0; i < STEPS; ++i) {
        float ang = 6.28318 * float(i) / float(STEPS);
        vec2 off = vec2(cos(ang), sin(ang)) * radius * texel;
        // Re-gather 3x3 around the offset sample. Yes this is a lot of taps;
        // it's the price of staying single-pass.
        DH_GATHER_DEPTH_3X3(inputImage, uv + off, texel, nD);
        float e = dh_depthEdgeSobel(nD, camera.projection);
        float m = dh_smoothstep(edgeThreshold, edgeThreshold + edgeSoftness, e);
        glowMask = max(glowMask, m * 0.65);  // attenuated contribution
    }

    // Glow is added light: premultiplied, it adds to the dimmed scene and
    // covers a transparent sky with its own strength.
    vec3  glow = glowColor.rgb * glowMask * glowIntensity;
    vec3  pm   = color.rgb * (1.0 - dimScene) * color.a + glow;
    float a    = max(color.a, clamp(glowMask * glowIntensity, 0.0, 1.0));
    vec4  withGlow = vec4(pm / max(a, DH_EPSILON), a);

    isf_FragColor = dh_paintOver(withGlow, edgeColor.rgb, coreMask);
    gl_FragDepth = rawD;
}
