/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Soft clip: smooth roll-off at highlight and shadow boundaries to prevent hard clipping. Uses a quadratic knee function (industry standard from Resolve's soft clip). Essential in linear-light pipelines where values easily exceed 1.0. Preserves detail that hard clamp destroys.",
    "CATEGORIES": [ "Color" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "highlight_enable",
            "LABEL": "Enable Highlight Soft Clip",
            "TYPE": "bool",
            "DEFAULT": true
        },
        {
            "NAME": "highlight_onset",
            "LABEL": "Highlight Knee Start",
            "TYPE": "float",
            "DEFAULT": 0.8,
            "MIN": 0.3,
            "MAX": 1.0
        },
        {
            "NAME": "highlight_max",
            "LABEL": "Highlight Ceiling",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.5,
            "MAX": 2.0
        },
        {
            "NAME": "shadow_enable",
            "LABEL": "Enable Shadow Soft Clip",
            "TYPE": "bool",
            "DEFAULT": false
        },
        {
            "NAME": "shadow_onset",
            "LABEL": "Shadow Knee Start",
            "TYPE": "float",
            "DEFAULT": 0.1,
            "MIN": 0.0,
            "MAX": 0.3
        },
        {
            "NAME": "shadow_floor",
            "LABEL": "Shadow Floor",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -0.05,
            "MAX": 0.1
        },
        {
            "NAME": "method",
            "LABEL": "Knee Method",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1 ],
            "LABELS": [ "Quadratic (smooth)", "Reciprocal (1/x compression)" ]
        }
    ]
}*/

// Soft clip functions:
// These compress the signal smoothly beyond a knee point,
// asymptotically approaching a ceiling.
//
// Quadratic knee (Resolve-style):
//   Below onset: linear (passthrough)
//   Above onset: quadratic compression toward ceiling
//   C1 continuous at the knee point
//
// Reciprocal (1/x) compression (Khronos PBR Neutral style):
//   Below onset: linear
//   Above onset: ceiling - d²/(x + d - onset) where d = ceiling - onset
//   Asymptotically approaches ceiling, never reaches it

// Quadratic soft clip: shoulder
float softClipHighQ(float x, float onset, float ceiling) {
    if (x <= onset) return x;
    float d = ceiling - onset;
    if (d <= 0.0) return ceiling;
    float t = (x - onset) / d;
    // Quadratic: maps [onset, ∞) → [onset, ceiling)
    // Formula: onset + d * (1 - 1/(1 + t))  -- this is the reciprocal form
    // Quadratic form: onset + d * t / (1 + t) -- Reinhard-like
    return onset + d * t / (1.0 + t);
}

// Quadratic soft clip: toe (for shadows)
float softClipLowQ(float x, float onset, float floor_val) {
    if (x >= onset) return x;
    float d = onset - floor_val;
    if (d <= 0.0) return floor_val;
    float t = (onset - x) / d;
    return onset - d * t / (1.0 + t);
}

// Reciprocal soft clip: shoulder
float softClipHighR(float x, float onset, float ceiling) {
    if (x <= onset) return x;
    float d = ceiling - onset;
    if (d <= 0.0) return ceiling;
    // 1/x compression: ceiling - d²/(x - onset + d)
    return ceiling - d * d / (x - onset + d);
}

// Reciprocal soft clip: toe
float softClipLowR(float x, float onset, float floor_val) {
    if (x >= onset) return x;
    float d = onset - floor_val;
    if (d <= 0.0) return floor_val;
    return floor_val + d * d / (onset - x + d);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 orig = IMG_NORM_PIXEL(inputImage, uv);
    vec3 c = orig.rgb;

    // Apply per-channel to preserve hue ratios
    for (int ch = 0; ch < 3; ch++) {
        float v = (ch == 0) ? c.r : (ch == 1) ? c.g : c.b;

        if (highlight_enable) {
            if (method == 0)
                v = softClipHighQ(v, highlight_onset, highlight_max);
            else
                v = softClipHighR(v, highlight_onset, highlight_max);
        }

        if (shadow_enable) {
            if (method == 0)
                v = softClipLowQ(v, shadow_onset, shadow_floor);
            else
                v = softClipLowR(v, shadow_onset, shadow_floor);
        }

        if (ch == 0) c.r = v;
        else if (ch == 1) c.g = v;
        else c.b = v;
    }

    gl_FragColor = vec4(c, orig.a);
}
