/*{
    "CREDIT": "ossia team; scatter-as-gather after D. Gustafsson (2018)",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Depth-of-field with bokeh-biased sampling. Bright pixels contribute more strongly, letting highlights form the characteristic disc / hexagonal bokeh. `bokehShape` selects the sample pattern. Single-pass scatter-as-gather: every tap is weighted by whether ITS OWN circle of confusion reaches this pixel, so a sharp subject does not bleed into the blurred background and a blurred foreground does spill over a sharp background (D. Gustafsson, 'Bokeh depth of field in a single pass', 2018). The circle of confusion is a stylised ramp: 0 within focusRange of focusDepth, reaching blurAmount pixels one more focusRange away (the physical thin-lens CoC, Potmesil & Chakravarty 1981, grows with |1/focus - 1/z| instead). The blur works on premultiplied colour and alpha, so a blurred silhouette also spreads over a transparent background.",
    "CATEGORIES": ["Post-process", "Focus"],
    "ALPHA": "premultiplied",

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
        { "NAME": "focusDepth", "TYPE": "float", "LABEL": "Focus depth (world units)",
          "DEFAULT": 8.0, "MIN": 0.01, "MAX": 1000.0 },
        { "NAME": "focusRange", "TYPE": "float", "LABEL": "Focus range (world units)",
          "DEFAULT": 1.5, "MIN": 0.0, "MAX": 100.0 },
        { "NAME": "blurAmount", "TYPE": "float", "LABEL": "Max blur radius (pixels)",
          "DEFAULT": 16.0, "MIN": 0.0, "MAX": 80.0 },
        { "NAME": "bokehShape", "TYPE": "long", "LABEL": "Bokeh shape",
          "VALUES": [0, 1, 2], "LABELS": ["Disc", "Hexagon", "Pentagon"], "DEFAULT": 0 },
        { "NAME": "highlightBias", "TYPE": "float", "LABEL": "Highlight bokeh bias",
          "DEFAULT": 1.5, "MIN": 0.0, "MAX": 5.0 }
    ]
}*/

#include "depth_helpers.glsl"

// Shape the radius by polygon: for angle a and vertex count n, returns the
// distance from centre to the polygon boundary at that angle.
float polyRadius(float a, float n)
{
    if (n < 2.5) return 1.0;  // disc
    float seg = 6.28318 / n;
    float half_seg = seg * 0.5;
    float theta = mod(a, seg) - half_seg;
    return cos(half_seg) / cos(theta);
}

vec2 bokehOffset(int i, int total, int shape)
{
    float t = (float(i) + 0.5) / float(total);
    float r = sqrt(t);
    float a = float(i) * 2.39996323;
    float vertexCount = (shape == 1) ? 6.0 : (shape == 2 ? 5.0 : 0.0);
    float shaped = (shape == 0) ? r : r * polyRadius(a, vertexCount);
    return vec2(cos(a), sin(a)) * shaped;
}

// Circle-of-confusion radius in pixels for a raw depth sample.
float cocRadius(float rawDepth)
{
    float eye = dh_linearizeDepth(rawDepth, camera.projection);
    float coc = max(abs(eye - focusDepth) - focusRange, 0.0);
    return clamp(coc / max(focusRange, 0.001), 0.0, 1.0) * blurAmount;
}

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL_PREMULTIPLIED(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);
    float radius = cocRadius(rawD);

    // Gather over the MAXIMUM radius, not this pixel's own: a sharp pixel
    // must still collect a blurred foreground that overlaps it.
    const int N = 48;
    vec2 texel = 1.0 / RENDERSIZE;
    vec4  acc  = color;
    float wsum = 1.0;
    for (int i = 0; i < N; ++i) {
        vec2  o  = bokehOffset(i, N, bokehShape);   // unit-disc / polygon
        float r  = length(o) * blurAmount;           // tap distance (px)
        vec2  sUV = uv + o * blurAmount * texel;
        float sRaw = IMG_DEPTH_NORM_PIXEL_LOD0(inputImage, sUV);
        vec4  s    = IMG_NORM_PIXEL_LOD0(inputImage, sUV);
        float sEye = dh_linearizeDepth(sRaw, camera.projection);
        float sCoc = cocRadius(sRaw);
        // A tap BEHIND this pixel cannot blur over it by more than this
        // pixel's own blur (Gustafsson's clamp): keeps a sharp subject from
        // leaking into the background around it.
        if (sEye > eye) sCoc = min(sCoc, radius);
        // Does the tap's own disc reach this pixel?
        float m = smoothstep(r - 1.0, r + 1.0, sCoc);
        // Highlight bias: brighter samples count more, shaping bokeh.
        float w = m * (1.0 + pow(dh_luma(s.rgb), 2.0) * highlightBias);
        acc  += s * w;
        wsum += w;
    }

    isf_FragColor = acc / wsum;
    gl_FragDepth = rawD;
}
