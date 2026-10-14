/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Manga-style edges with animated hatching. Draws depth-Sobel outlines AND fills shadow areas (low luma) with a scrolling cross-hatch pattern that moves over time, giving the scene a lively hand-inked feel. Paper, hatching and outlines are painted over the input: a transparent background becomes paper (at Paper lift amount) and keeps its outlines.",
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

        { "NAME": "edgeColor", "TYPE": "color",
          "LABEL": "Outline / hatch colour",
          "DEFAULT": [0.05, 0.05, 0.05, 1.0] },
        { "NAME": "paperColor", "TYPE": "color",
          "LABEL": "Paper colour",
          "DEFAULT": [0.95, 0.94, 0.88, 1.0] },

        { "NAME": "edgeThreshold", "TYPE": "float",
          "LABEL": "Edge threshold (relative depth jump, 0.1 = 10%)",
          "DEFAULT": 0.05, "MIN": 0.0, "MAX": 5.0 },
        { "NAME": "edgeSoftness", "TYPE": "float",
          "LABEL": "Edge softness (relative depth jump)",
          "DEFAULT": 0.03, "MIN": 0.0, "MAX": 2.0 },

        { "NAME": "hatchScale", "TYPE": "float",
          "LABEL": "Hatch line density",
          "DEFAULT": 80.0, "MIN": 5.0, "MAX": 400.0 },
        { "NAME": "hatchSpeed", "TYPE": "float",
          "LABEL": "Hatch scroll speed",
          "DEFAULT": 0.6, "MIN": 0.0, "MAX": 8.0 },
        { "NAME": "hatchAngle", "TYPE": "float",
          "LABEL": "Hatch angle (degrees)",
          "DEFAULT": 45.0, "MIN": 0.0, "MAX": 180.0 },

        { "NAME": "shadowThreshold", "TYPE": "float",
          "LABEL": "Shadow threshold (luma below which hatching starts)",
          "DEFAULT": 0.55, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "paperAmount", "TYPE": "float",
          "LABEL": "Paper lift amount",
          "DEFAULT": 0.6, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);

    vec2 texel = 1.0 / RENDERSIZE;

    // --- Depth edge ---
    float nD[9];
    DH_GATHER_DEPTH_3X3(inputImage, uv, texel, nD);
    float edge = dh_depthEdgeSobel(nD, camera.projection);
    float edgeMask = dh_smoothstep(edgeThreshold, edgeThreshold + edgeSoftness, edge);

    // --- Hatch pattern ---
    // Rotate UV (in pixels) by hatchAngle, extract a 1D stripe coordinate,
    // scroll it with time, then test against a periodic threshold.
    float angRad = radians(hatchAngle);
    vec2 p = uv * RENDERSIZE;  // pixel space so hatchScale lives in "lines per image diagonal" units
    float cs = cos(angRad);
    float sn = sin(angRad);
    float stripe = (p.x * cs + p.y * sn) / max(RENDERSIZE.x, RENDERSIZE.y);
    stripe = stripe * hatchScale + TIME * hatchSpeed;
    // Thin ink line at the stripe boundary (|fract - 0.5| near 0.5): about
    // 15% ink per period. (Was 1 - smoothstep(0.4, 0.5, ..), i.e. 80% ink.)
    float hatch = smoothstep(0.38, 0.46, abs(fract(stripe) - 0.5));

    // Hatch intensity rises with darkness: luma below `shadowThreshold`
    // opens the hatching up.
    float luma = dh_luma(color.rgb);
    // 1 in black, 0 at shadowThreshold and above. dh_smoothstep needs
    // e0 < e1 (it clamps the denominator to +epsilon), so the reversed call
    // dh_smoothstep(shadowThreshold, 0.0, luma) was a hard step that hatched
    // the BRIGHT areas instead.
    // Scaled by coverage: an empty (transparent) background is paper, not
    // shadow.
    float hatchMask = hatch * (1.0 - dh_smoothstep(0.0, shadowThreshold, luma)) * color.a;

    // --- Composite: paper, hatching and outlines are painted over the scene ---
    vec4 outColor = dh_paintOver(color, paperColor.rgb, paperAmount);
    outColor = dh_paintOver(outColor, edgeColor.rgb, hatchMask);
    outColor = dh_paintOver(outColor, edgeColor.rgb, edgeMask);

    isf_FragColor = outColor;
    gl_FragDepth = rawD;
}
