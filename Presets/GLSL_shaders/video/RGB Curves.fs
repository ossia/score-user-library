/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Parametric RGB curves. Adjusts contrast and color balance using smooth adjustments at shadow, midtone, and highlight zones. Per-channel R/G/B curves for split-toning; master luminance curve for contrast. Equivalent to Resolve's Custom Curves / Lightroom's Parametric Tone Curve. All sliders at 0 = perfect identity (no change). Works in linear or gamma space.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "master_shadows",
            "LABEL": "Master Shadows",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.5,
            "MAX": 0.5
        },
        {
            "NAME": "master_midtones",
            "LABEL": "Master Midtones",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.5,
            "MAX": 0.5
        },
        {
            "NAME": "master_highlights",
            "LABEL": "Master Highlights",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.5,
            "MAX": 0.5
        },
        {
            "NAME": "red_shadows",
            "LABEL": "Red Shadows",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.5,
            "MAX": 0.5
        },
        {
            "NAME": "red_highlights",
            "LABEL": "Red Highlights",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.5,
            "MAX": 0.5
        },
        {
            "NAME": "green_shadows",
            "LABEL": "Green Shadows",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.5,
            "MAX": 0.5
        },
        {
            "NAME": "green_highlights",
            "LABEL": "Green Highlights",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.5,
            "MAX": 0.5
        },
        {
            "NAME": "blue_shadows",
            "LABEL": "Blue Shadows",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.5,
            "MAX": 0.5
        },
        {
            "NAME": "blue_highlights",
            "LABEL": "Blue Highlights",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.5,
            "MAX": 0.5
        }
    ]
}*/

// Zone-based curve adjustment using additive bumps on the identity line.
//
// Each zone (shadow, midtone, highlight) contributes a smooth bell-shaped
// adjustment centered at its tonal position. When the slider is 0, the
// bump is zero and output = input (perfect identity guaranteed).
//
// This is how Lightroom's parametric tone curve works: four draggable
// zones that add to / subtract from the diagonal.

// Quadratic bell: peaks at center, falls to 0 at center ± width
float bell(float x, float center, float width) {
    float d = (x - center) / width;
    return max(1.0 - d * d, 0.0);
}

float applyCurve(float x, float shadowAdj, float midAdj, float highAdj) {
    float t = clamp(x, 0.0, 1.0);

    // Three overlapping soft zones, each a quadratic bell
    float adj = bell(t, 0.25, 0.35) * shadowAdj
              + bell(t, 0.50, 0.35) * midAdj
              + bell(t, 0.75, 0.35) * highAdj;

    float result = t + adj;

    // HDR extension: values > 1.0 pass through with adjusted slope
    if (x > 1.0) {
        float slopeAtOne = 1.0 + highAdj * 0.3;
        slopeAtOne = max(slopeAtOne, 0.1);
        float valAtOne = 1.0 + bell(1.0, 0.25, 0.35) * shadowAdj
                             + bell(1.0, 0.50, 0.35) * midAdj
                             + bell(1.0, 0.75, 0.35) * highAdj;
        result = valAtOne + slopeAtOne * (x - 1.0);
    }

    return max(result, 0.0);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    // Early out when all sliders are zero
    bool masterActive = (master_shadows != 0.0 || master_midtones != 0.0 || master_highlights != 0.0);
    bool redActive    = (red_shadows != 0.0 || red_highlights != 0.0);
    bool greenActive  = (green_shadows != 0.0 || green_highlights != 0.0);
    bool blueActive   = (blue_shadows != 0.0 || blue_highlights != 0.0);

    if (!masterActive && !redActive && !greenActive && !blueActive) {
        gl_FragColor = orig;
        return;
    }

    // Master curve (all channels)
    if (masterActive) {
        c.r = applyCurve(c.r, master_shadows, master_midtones, master_highlights);
        c.g = applyCurve(c.g, master_shadows, master_midtones, master_highlights);
        c.b = applyCurve(c.b, master_shadows, master_midtones, master_highlights);
    }

    // Per-channel curves
    // Auto-derive midtone from shadow+highlight: when they're opposite
    // (e.g. shadow +0.2, highlight -0.2), the midtone counter-adjusts
    // to create a smooth S-curve without a midtone slider.
    if (redActive) {
        float mid = (red_shadows + red_highlights) * -0.25;
        c.r = applyCurve(c.r, red_shadows, mid, red_highlights);
    }
    if (greenActive) {
        float mid = (green_shadows + green_highlights) * -0.25;
        c.g = applyCurve(c.g, green_shadows, mid, green_highlights);
    }
    if (blueActive) {
        float mid = (blue_shadows + blue_highlights) * -0.25;
        c.b = applyCurve(c.b, blue_shadows, mid, blue_highlights);
    }

    gl_FragColor = vec4(c, orig.a);
}
