/*{
    "CREDIT": "ossia score video utilities",
    "ISFVSN": "2",
    "DESCRIPTION": "Test pattern generator for calibrating and debugging the video pipeline. Generates color bars, gray ramps, primary patches, and HDR luminance steps. Mix with input or use standalone.",
    "CATEGORIES": [
        "Color"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },
        {
            "NAME": "pattern",
            "LABEL": "Pattern",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2, 3, 4 ],
            "LABELS":  [
                "SMPTE Color Bars",
                "Grayscale Ramp",
                "RGB Primaries + CMY",
                "HDR Luminance Steps",
                "Gradient (custom range)"
            ]
        },
        {
            "NAME": "mix_input",
            "LABEL": "Mix with Input",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": 0.0,
            "MAX": 1.0
        },
        {
            "NAME": "gradient_min",
            "LABEL": "Gradient Min",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -1.0,
            "MAX": 10.0
        },
        {
            "NAME": "gradient_max",
            "LABEL": "Gradient Max",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 50.0
        }
    ]
}*/

// SMPTE-style color bars (simplified 75% bars)
vec3 smpte_bars(vec2 uv) {
    // Top 2/3: 75% color bars
    // Bottom 1/3: reverse bars + black/white reference
    float x = uv.x;
    float y = uv.y;

    if (y > 0.33) {
        // Main bars: White, Yellow, Cyan, Green, Magenta, Red, Blue
        float bar = floor(x * 7.0);
        if (bar == 0.0) return vec3(0.75);                      // White
        if (bar == 1.0) return vec3(0.75, 0.75, 0.0);           // Yellow
        if (bar == 2.0) return vec3(0.0, 0.75, 0.75);           // Cyan
        if (bar == 3.0) return vec3(0.0, 0.75, 0.0);            // Green
        if (bar == 4.0) return vec3(0.75, 0.0, 0.75);           // Magenta
        if (bar == 5.0) return vec3(0.75, 0.0, 0.0);            // Red
        return vec3(0.0, 0.0, 0.75);                             // Blue
    } else if (y > 0.17) {
        // PLUGE area: near-black reference steps
        float bar = floor(x * 7.0);
        if (bar == 0.0) return vec3(0.0, 0.0, 0.75);            // Blue
        if (bar == 1.0) return vec3(0.0);                        // Black
        if (bar == 2.0) return vec3(0.75, 0.0, 0.75);           // Magenta
        if (bar == 3.0) return vec3(0.0);                        // Black
        if (bar == 4.0) return vec3(0.0, 0.75, 0.75);           // Cyan
        if (bar == 5.0) return vec3(0.0);                        // Black
        return vec3(0.75);                                        // White
    } else {
        // Bottom: PLUGE blacks + 100% white
        float pos = x * 4.0;
        if (pos < 1.0) return vec3(-2.0 / 100.0);               // Sub-black (for range test)
        if (pos < 2.0) return vec3(0.0);                         // Black
        if (pos < 3.0) return vec3(2.0 / 100.0);                // Near-black (+2%)
        return vec3(1.0);                                         // 100% white
    }
}

// Grayscale ramp (11 steps, broadcast standard)
vec3 gray_ramp(vec2 uv) {
    if (uv.y > 0.5) {
        // Smooth gradient (top half)
        return vec3(uv.x);
    } else {
        // 11-step staircase (bottom half)
        float step_val = floor(uv.x * 11.0) / 10.0;
        return vec3(step_val);
    }
}

// Primary and secondary color patches
vec3 primary_patches(vec2 uv) {
    float col = floor(uv.x * 6.0);
    float row = floor(uv.y * 3.0);

    if (row >= 2.0) {
        // Top: 100% primaries + secondaries
        if (col == 0.0) return vec3(1.0, 0.0, 0.0);     // Red
        if (col == 1.0) return vec3(0.0, 1.0, 0.0);     // Green
        if (col == 2.0) return vec3(0.0, 0.0, 1.0);     // Blue
        if (col == 3.0) return vec3(0.0, 1.0, 1.0);     // Cyan
        if (col == 4.0) return vec3(1.0, 0.0, 1.0);     // Magenta
        return vec3(1.0, 1.0, 0.0);                       // Yellow
    } else if (row >= 1.0) {
        // Middle: 75% versions
        if (col == 0.0) return vec3(0.75, 0.0, 0.0);
        if (col == 1.0) return vec3(0.0, 0.75, 0.0);
        if (col == 2.0) return vec3(0.0, 0.0, 0.75);
        if (col == 3.0) return vec3(0.0, 0.75, 0.75);
        if (col == 4.0) return vec3(0.75, 0.0, 0.75);
        return vec3(0.75, 0.75, 0.0);
    } else {
        // Bottom: skin tones and grays
        if (col == 0.0) return vec3(0.78, 0.57, 0.44);   // Light skin
        if (col == 1.0) return vec3(0.54, 0.36, 0.26);   // Dark skin
        if (col == 2.0) return vec3(0.18);                 // 18% gray
        if (col == 3.0) return vec3(0.36);                 // Mid gray
        if (col == 4.0) return vec3(0.59);                 // Light gray
        return vec3(0.90);                                  // Near-white
    }
}

// HDR luminance steps (in nits, useful for PQ calibration)
// Outputs linear values where 1.0 = 100 nits (SDR reference)
vec3 hdr_steps(vec2 uv) {
    float col = floor(uv.x * 8.0);
    float nits;

    // Nits levels: 0.5, 1, 5, 20, 100, 203, 400, 1000
    if (col == 0.0)      nits = 0.5;
    else if (col == 1.0) nits = 1.0;
    else if (col == 2.0) nits = 5.0;
    else if (col == 3.0) nits = 20.0;
    else if (col == 4.0) nits = 100.0;
    else if (col == 5.0) nits = 203.0;
    else if (col == 6.0) nits = 400.0;
    else                  nits = 1000.0;

    // Output as normalized linear (1.0 = 100 nits for basic display)
    return vec3(nits / 100.0);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec3 patternColor;

    if (pattern == 0)      patternColor = smpte_bars(uv);
    else if (pattern == 1) patternColor = gray_ramp(uv);
    else if (pattern == 2) patternColor = primary_patches(uv);
    else if (pattern == 3) patternColor = hdr_steps(uv);
    else                    patternColor = vec3(mix(gradient_min, gradient_max, uv.x));

    vec3 input_col = IMG_THIS_PIXEL(inputImage).rgb;
    vec3 result = mix(patternColor, input_col, mix_input);

    gl_FragColor = vec4(result, 1.0);
}
